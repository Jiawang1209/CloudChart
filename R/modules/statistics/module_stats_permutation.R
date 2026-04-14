stats_permutation_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())
      sync_column_choices(
        session, df(),
        c("group_var","value_var"),
        selected_map = list(
          group_var = bgc_pick_column(input$group_var, discrete_cols[1]),
          value_var = bgc_pick_column(input$value_var, numeric_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    perm_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$group_var), nzchar(input$value_var))
      validate_required_columns(df(), c(input$group_var, input$value_var))
      validate_numeric_columns(df(), input$value_var)

      group_values <- df()[[input$group_var]]
      value_values <- df()[[input$value_var]]
      keep <- !is.na(group_values) & !is.na(value_values)
      group_values <- group_values[keep]
      value_values <- value_values[keep]

      groups <- unique(group_values)
      validate(need(length(groups) == 2,
                    paste0("Permutation test requires exactly 2 groups, got ", length(groups), ".")))

      x <- value_values[group_values == groups[1]]
      y <- value_values[group_values == groups[2]]
      observed <- mean(x) - mean(y)

      set.seed(input$seed)
      pooled <- c(x, y)
      n_x <- length(x)
      n_perm <- input$n_perm
      diffs <- replicate(n_perm, {
        idx <- sample.int(length(pooled), n_x, replace = FALSE)
        mean(pooled[idx]) - mean(pooled[-idx])
      })

      p_value <- switch(
        input$alternative,
        two.sided = mean(abs(diffs) >= abs(observed)),
        greater   = mean(diffs >= observed),
        less      = mean(diffs <= observed)
      )

      list(
        groups = as.character(groups),
        n1 = length(x), n2 = length(y),
        observed = observed,
        p_value = p_value,
        diffs = diffs,
        n_perm = n_perm,
        alternative = input$alternative
      )
    })

    print_fn <- function(){
      fit <- perm_fit()
      cat(sprintf(
        "Permutation test (mean difference)\n  Groups: %s (n=%d) vs %s (n=%d)\n  Observed difference: %.4f\n  Permutations: %d\n  Alternative: %s\n  p-value: %.4g\n",
        fit$groups[1], fit$n1, fit$groups[2], fit$n2,
        fit$observed, fit$n_perm, fit$alternative, fit$p_value
      ))
    }

    table_fn <- function(){
      fit <- perm_fit()
      data.frame(
        Statistic = c("group1","group2","n1","n2","observed_diff","n_perm","alternative","p.value"),
        Value = c(fit$groups[1], fit$groups[2], fit$n1, fit$n2,
                  round(fit$observed, 6), fit$n_perm, fit$alternative,
                  signif(fit$p_value, 6)),
        stringsAsFactors = FALSE
      )
    }

    plot_fn <- function(){
      fit <- perm_fit()
      op <- par(mar = c(4.5, 4.5, 3, 1))
      on.exit(par(op), add = TRUE)
      hist(fit$diffs, breaks = 60, col = "#cfe1f2", border = "#1f3b5b",
           main = sprintf("Permutation null (n=%d), p = %.4g", fit$n_perm, fit$p_value),
           xlab = "Mean difference under H0")
      abline(v = fit$observed, col = "#c1121f", lwd = 2)
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "permutation_test", plot_fn)
  })
}
