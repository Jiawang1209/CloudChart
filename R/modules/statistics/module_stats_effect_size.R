stats_effect_size_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols  <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session,
        df(),
        c("group_var", "value_var", "row_var", "col_var"),
        selected_map = list(
          group_var = bgc_pick_column(input$group_var, discrete_cols[1]),
          value_var = bgc_pick_column(input$value_var, numeric_cols[1]),
          row_var   = bgc_pick_column(input$row_var,   discrete_cols[1]),
          col_var   = bgc_pick_column(input$col_var,   discrete_cols[2])
        )
      )
    }, ignoreNULL = FALSE)

    effect_fit <- eventReactive(input$run_analysis, {
      method <- input$method
      validate(need(nzchar(method), "Select an effect size method."))

      if (method == "cohen_d") {
        req(nzchar(input$group_var), nzchar(input$value_var))
        validate_required_columns(df(), c(input$group_var, input$value_var))
        validate_numeric_columns(df(), input$value_var)

        group <- factor(df()[[input$group_var]])
        value <- df()[[input$value_var]]
        keep  <- !is.na(group) & !is.na(value)
        group <- droplevels(group[keep])
        value <- value[keep]

        validate(
          need(nlevels(group) == 2,
               paste0("Cohen's d requires exactly 2 groups, got ", nlevels(group), "."))
        )

        lv  <- levels(group)
        x1  <- value[group == lv[1]]
        x2  <- value[group == lv[2]]
        n1  <- length(x1); n2 <- length(x2)
        s1  <- var(x1);    s2 <- var(x2)
        pooled_sd <- sqrt(((n1 - 1) * s1 + (n2 - 1) * s2) / (n1 + n2 - 2))
        d <- (mean(x1) - mean(x2)) / pooled_sd
        magnitude <- bgc_cohen_magnitude(abs(d))

        list(
          label = sprintf("Cohen's d (%s vs %s)", lv[1], lv[2]),
          print_lines = c(
            sprintf("Group 1: %s  n=%d  mean=%.4f  sd=%.4f", lv[1], n1, mean(x1), sd(x1)),
            sprintf("Group 2: %s  n=%d  mean=%.4f  sd=%.4f", lv[2], n2, mean(x2), sd(x2)),
            sprintf("Pooled SD: %.4f", pooled_sd),
            sprintf("Cohen's d: %.4f (%s)", d, magnitude)
          ),
          table_df = data.frame(
            Metric = c("n1", "n2", "mean1", "mean2", "pooled_sd", "cohen_d", "magnitude"),
            Value  = c(n1, n2, mean(x1), mean(x2), pooled_sd, d, magnitude),
            stringsAsFactors = FALSE
          )
        )
      } else if (method == "eta_sq") {
        req(nzchar(input$group_var), nzchar(input$value_var))
        validate_required_columns(df(), c(input$group_var, input$value_var))
        validate_numeric_columns(df(), input$value_var)

        data_subset <- data.frame(
          value = df()[[input$value_var]],
          group = factor(df()[[input$group_var]])
        )
        data_subset <- data_subset[complete.cases(data_subset), , drop = FALSE]
        data_subset$group <- droplevels(data_subset$group)

        validate(need(nlevels(data_subset$group) >= 2,
                      "Eta-squared requires at least 2 groups."))

        fit <- aov(value ~ group, data = data_subset)
        ss  <- summary(fit)[[1]][["Sum Sq"]]
        ss_between <- ss[1]
        ss_total   <- sum(ss)
        eta2       <- ss_between / ss_total
        df_b <- summary(fit)[[1]][["Df"]][1]
        df_w <- summary(fit)[[1]][["Df"]][2]
        partial_eta2 <- ss_between / (ss_between + ss[2])
        omega2 <- (ss_between - df_b * (ss[2] / df_w)) / (ss_total + (ss[2] / df_w))
        magnitude <- bgc_eta_magnitude(eta2)

        list(
          label = "Eta-squared (one-way ANOVA)",
          print_lines = c(
            sprintf("SS between: %.4f  (df=%d)", ss_between, df_b),
            sprintf("SS within:  %.4f  (df=%d)", ss[2], df_w),
            sprintf("SS total:   %.4f", ss_total),
            sprintf("Eta-squared:        %.4f (%s)", eta2, magnitude),
            sprintf("Partial eta-squared: %.4f", partial_eta2),
            sprintf("Omega-squared:       %.4f", omega2)
          ),
          table_df = data.frame(
            Metric = c("ss_between", "ss_within", "ss_total",
                       "eta_sq", "partial_eta_sq", "omega_sq", "magnitude"),
            Value  = c(ss_between, ss[2], ss_total,
                       eta2, partial_eta2, omega2, magnitude),
            stringsAsFactors = FALSE
          )
        )
      } else {
        req(nzchar(input$row_var), nzchar(input$col_var))
        validate(need(input$row_var != input$col_var,
                      "Row and column variables must be different."))
        validate_required_columns(df(), c(input$row_var, input$col_var))

        row_vals <- df()[[input$row_var]]
        col_vals <- df()[[input$col_var]]
        keep <- !is.na(row_vals) & !is.na(col_vals)

        tab <- table(factor(row_vals[keep]), factor(col_vals[keep]))
        validate(
          need(nrow(tab) >= 2 && ncol(tab) >= 2,
               "Cramer's V requires at least 2 rows and 2 columns."),
          need(sum(tab) >= 2, "Not enough observations after removing NAs.")
        )

        chi <- suppressWarnings(chisq.test(tab))
        n   <- sum(tab)
        k   <- min(nrow(tab), ncol(tab))
        cramers_v <- sqrt(unname(chi$statistic) / (n * (k - 1)))
        phi <- if (nrow(tab) == 2 && ncol(tab) == 2) {
          sqrt(unname(chi$statistic) / n)
        } else NA_real_
        magnitude <- bgc_cramer_magnitude(cramers_v, k)

        list(
          label = "Cramer's V (contingency table)",
          print_lines = c(
            sprintf("Table: %d x %d, n = %d", nrow(tab), ncol(tab), n),
            sprintf("Chi-square: %.4f  df = %d  p = %.4g",
                    unname(chi$statistic), unname(chi$parameter), chi$p.value),
            sprintf("Cramer's V: %.4f (%s)", cramers_v, magnitude),
            if (!is.na(phi)) sprintf("Phi (2x2):  %.4f", phi) else "Phi (2x2):  NA"
          ),
          table_df = data.frame(
            Metric = c("n", "chi_square", "df", "p_value",
                       "cramers_v", "phi", "magnitude"),
            Value  = c(n, unname(chi$statistic), unname(chi$parameter), chi$p.value,
                       cramers_v, phi, magnitude),
            stringsAsFactors = FALSE
          )
        )
      }
    })

    print_fn <- function(){
      res <- effect_fit()
      cat(sprintf("=== %s ===\n", res$label))
      for (line in res$print_lines) cat(line, "\n")
    }

    table_fn <- function(){
      effect_fit()$table_df
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "effect_size")
  })
}

bgc_cohen_magnitude <- function(d_abs) {
  if (is.na(d_abs)) return("NA")
  if (d_abs < 0.2) "negligible"
  else if (d_abs < 0.5) "small"
  else if (d_abs < 0.8) "medium"
  else "large"
}

bgc_eta_magnitude <- function(eta2) {
  if (is.na(eta2)) return("NA")
  if (eta2 < 0.01) "negligible"
  else if (eta2 < 0.06) "small"
  else if (eta2 < 0.14) "medium"
  else "large"
}

bgc_cramer_magnitude <- function(v, k) {
  if (is.na(v) || is.na(k) || k < 2) return("NA")
  df_cv <- k - 1
  small  <- 0.1 / sqrt(df_cv)
  medium <- 0.3 / sqrt(df_cv)
  large  <- 0.5 / sqrt(df_cv)
  if (v < small) "negligible"
  else if (v < medium) "small"
  else if (v < large)  "medium"
  else "large"
}
