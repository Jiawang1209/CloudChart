stats_posthoc_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session,
        df(),
        c("group_var", "value_var"),
        selected_map = list(
          group_var = bgc_pick_column(input$group_var, discrete_cols[1]),
          value_var = bgc_pick_column(input$value_var, numeric_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    posthoc_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$group_var), nzchar(input$value_var))
      validate_required_columns(df(), c(input$group_var, input$value_var))
      validate_numeric_columns(df(), input$value_var)

      data_subset <- data.frame(
        value = df()[[input$value_var]],
        group = factor(df()[[input$group_var]])
      )
      data_subset <- data_subset[complete.cases(data_subset), , drop = FALSE]
      data_subset$group <- droplevels(data_subset$group)

      validate(
        need(nlevels(data_subset$group) >= 2, "Post-hoc tests require at least 2 groups."),
        need(nlevels(data_subset$group) <= 30, "Too many groups (>30) for pairwise comparison."),
        need(nrow(data_subset) >= 3, "Not enough observations after removing NAs.")
      )

      method <- input$method
      p_adjust <- input$p_adjust

      if (method == "tukey") {
        fit <- aov(value ~ group, data = data_subset)
        tk <- TukeyHSD(fit)$group
        table_df <- data.frame(
          Comparison = rownames(tk),
          Estimate   = tk[, "diff"],
          ci.lower   = tk[, "lwr"],
          ci.upper   = tk[, "upr"],
          p.adj      = tk[, "p adj"],
          stringsAsFactors = FALSE,
          row.names = NULL
        )
        list(method_label = "Tukey HSD", raw = tk, table_df = table_df, anova = summary(fit))
      } else if (method == "pairwise_t") {
        result <- suppressWarnings(pairwise.t.test(
          data_subset$value, data_subset$group,
          p.adjust.method = p_adjust, pool.sd = TRUE
        ))
        list(
          method_label = paste0("Pairwise t-test (", p_adjust, ")"),
          raw = result,
          table_df = bgc_pairwise_matrix_to_df(result$p.value)
        )
      } else {
        result <- suppressWarnings(pairwise.wilcox.test(
          data_subset$value, data_subset$group,
          p.adjust.method = p_adjust
        ))
        list(
          method_label = paste0("Pairwise Wilcoxon (", p_adjust, ")"),
          raw = result,
          table_df = bgc_pairwise_matrix_to_df(result$p.value)
        )
      }
    })

    print_fn <- function(){
      fit <- posthoc_fit()
      cat(sprintf("=== %s ===\n", fit$method_label))
      if (!is.null(fit$anova)) {
        cat("\n--- Underlying ANOVA ---\n")
        print(fit$anova)
        cat("\n--- Pairwise Comparisons ---\n")
      }
      print(fit$raw)
    }

    table_fn <- function(){
      posthoc_fit()$table_df
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "post_hoc")
  })
}

bgc_pairwise_matrix_to_df <- function(pmat){
  rows <- list()
  for (r in rownames(pmat)) {
    for (c in colnames(pmat)) {
      if (!is.na(pmat[r, c])) {
        rows[[length(rows) + 1]] <- data.frame(
          Comparison = paste0(r, " vs ", c),
          p.adj = pmat[r, c],
          stringsAsFactors = FALSE
        )
      }
    }
  }
  if (length(rows) == 0) {
    return(data.frame(Comparison = character(), p.adj = numeric(), stringsAsFactors = FALSE))
  }
  do.call(rbind, rows)
}
