stats_survival_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session,
        df(),
        c("time_var", "status_var", "group_var"),
        selected_map = list(
          time_var   = bgc_pick_column(input$time_var, numeric_cols[1]),
          status_var = bgc_pick_column(input$status_var, numeric_cols[2]),
          group_var  = bgc_pick_column(input$group_var, discrete_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    survival_fit <- eventReactive(input$run_analysis, {
      validate(
        need(requireNamespace("survival", quietly = TRUE),
             "The 'survival' package is required. Install it with install.packages('survival').")
      )
      req(nzchar(input$time_var), nzchar(input$status_var))
      validate_required_columns(df(), c(input$time_var, input$status_var))
      validate_numeric_columns(df(), c(input$time_var, input$status_var))

      cols <- c(input$time_var, input$status_var)
      has_group <- nzchar(input$group_var) && !identical(input$group_var, input$time_var) &&
                   !identical(input$group_var, input$status_var)
      if (has_group) {
        validate_required_columns(df(), input$group_var)
        cols <- c(cols, input$group_var)
      }

      data_subset <- df()[, cols, drop = FALSE]
      data_subset <- data_subset[complete.cases(data_subset), , drop = FALSE]

      time_vals   <- data_subset[[input$time_var]]
      status_vals <- data_subset[[input$status_var]]

      validate(
        need(all(time_vals >= 0),
             "Time variable must be non-negative."),
        need(all(status_vals %in% c(0, 1)),
             "Status variable must only contain 0 (censored) or 1 (event)."),
        need(nrow(data_subset) >= 3,
             "Not enough observations after removing NAs.")
      )

      surv_obj <- survival::Surv(time = time_vals, event = status_vals)

      if (has_group) {
        group_factor <- factor(data_subset[[input$group_var]])
        validate(
          need(nlevels(droplevels(group_factor)) >= 2,
               "Group variable must have at least 2 levels.")
        )
        data_subset$.group <- group_factor
        fit <- survival::survfit(
          surv_obj ~ .group,
          data = data_subset,
          conf.int = input$conf_level
        )
        diff <- survival::survdiff(
          surv_obj ~ .group,
          data = data_subset,
          rho = as.numeric(input$rho)
        )
      } else {
        fit <- survival::survfit(
          surv_obj ~ 1,
          conf.int = input$conf_level
        )
        diff <- NULL
      }

      list(fit = fit, diff = diff, n = nrow(data_subset), has_group = has_group)
    })

    print_fn <- function(){
      result <- survival_fit()
      cat(sprintf("Observations used: %d\n\n", result$n))
      cat("=== Survival Fit Summary ===\n")
      print(result$fit)
      if (!is.null(result$diff)) {
        cat("\n=== Log-rank Test ===\n")
        print(result$diff)
      }
    }

    table_fn <- function(){
      result <- survival_fit()
      fit <- result$fit
      smry <- summary(fit)$table

      if (is.matrix(smry)) {
        out <- as.data.frame(smry, stringsAsFactors = FALSE)
        out <- cbind(Stratum = rownames(out), out)
        rownames(out) <- NULL
      } else {
        out <- data.frame(
          Stratum = "overall",
          t(smry),
          stringsAsFactors = FALSE
        )
      }

      if (!is.null(result$diff)) {
        diff <- result$diff
        chisq <- diff$chisq
        df_val <- length(diff$n) - 1
        p_val <- stats::pchisq(chisq, df = df_val, lower.tail = FALSE)
        logrank_row <- data.frame(
          Stratum = "LOG-RANK",
          records = NA, n.max = NA, n.start = NA, events = chisq,
          `rmean` = df_val, `se(rmean)` = NA, median = p_val,
          `0.95LCL` = NA, `0.95UCL` = NA,
          check.names = FALSE, stringsAsFactors = FALSE
        )
        out <- tryCatch(
          rbind(out, logrank_row[, intersect(names(logrank_row), names(out)), drop = FALSE]),
          error = function(e) out
        )
      }
      out
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "survival_km")
  })
}
