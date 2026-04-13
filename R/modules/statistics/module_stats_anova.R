stats_anova_Server <- function(id){
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

    anova_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$group_var), nzchar(input$value_var))
      validate_required_columns(df(), c(input$group_var, input$value_var))
      validate_numeric_columns(df(), input$value_var)

      data_subset <- data.frame(
        value = df()[[input$value_var]],
        group = factor(df()[[input$group_var]])
      )
      data_subset <- data_subset[complete.cases(data_subset), , drop = FALSE]

      validate(
        need(nlevels(droplevels(data_subset$group)) >= 2, "ANOVA requires at least 2 groups."),
        need(nrow(data_subset) >= 3, "Not enough observations after removing NAs.")
      )

      aov(value ~ group, data = data_subset)
    })

    print_fn <- function(){
      fit <- anova_fit()
      cat("=== One-way ANOVA ===\n")
      print(summary(fit))
      if (identical(input$post_hoc, "tukey")) {
        cat("\n=== Tukey HSD ===\n")
        print(TukeyHSD(fit))
      }
    }

    table_fn <- function(){
      fit <- anova_fit()
      if (identical(input$post_hoc, "tukey")) {
        tk <- TukeyHSD(fit)$group
        data.frame(
          Comparison = rownames(tk),
          diff = tk[, "diff"],
          ci.lower = tk[, "lwr"],
          ci.upper = tk[, "upr"],
          p.adj = tk[, "p adj"],
          stringsAsFactors = FALSE,
          row.names = NULL
        )
      } else {
        tab <- as.data.frame(summary(fit)[[1]])
        tab <- cbind(Term = rownames(tab), tab)
        rownames(tab) <- NULL
        tab
      }
    }

    plot_fn <- function(){
      fit <- anova_fit()
      if (identical(input$post_hoc, "tukey")) {
        op <- par(mfrow = c(1, 2), mar = c(4.5, 4.5, 3, 1))
        on.exit(par(op), add = TRUE)
        boxplot(
          value ~ group, data = fit$model,
          col = "#8ecae6", border = "#1f3b5b",
          main = "Group distributions",
          xlab = input$group_var, ylab = input$value_var
        )
        tryCatch(
          plot(TukeyHSD(fit), las = 1, col = "#d62828"),
          error = function(e) {
            plot.new(); title(main = paste("TukeyHSD plot failed:", conditionMessage(e)))
          }
        )
      } else {
        op <- par(mar = c(4.5, 4.5, 3, 1))
        on.exit(par(op), add = TRUE)
        boxplot(
          value ~ group, data = fit$model,
          col = "#8ecae6", border = "#1f3b5b",
          main = sprintf(
            "%s by %s (ANOVA p = %.4g)",
            input$value_var, input$group_var,
            summary(fit)[[1]][["Pr(>F)"]][1]
          ),
          xlab = input$group_var, ylab = input$value_var
        )
      }
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "anova", plot_fn)
  })
}
