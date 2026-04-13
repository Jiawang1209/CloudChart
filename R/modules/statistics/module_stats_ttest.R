stats_ttest_Server <- function(id){
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

    ttest_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$group_var), nzchar(input$value_var))
      validate_required_columns(df(), c(input$group_var, input$value_var))
      validate_numeric_columns(df(), input$value_var)

      group_values <- df()[[input$group_var]]
      value_values <- df()[[input$value_var]]

      keep <- !is.na(group_values) & !is.na(value_values)
      group_values <- group_values[keep]
      value_values <- value_values[keep]

      groups <- unique(group_values)
      validate(
        need(
          length(groups) == 2,
          paste0("t-test requires exactly 2 groups, got ", length(groups), ".")
        )
      )

      x <- value_values[group_values == groups[1]]
      y <- value_values[group_values == groups[2]]

      result <- t.test(
        x, y,
        alternative = input$alternative,
        var.equal = identical(input$var_equal, "yes"),
        conf.level = input$conf_level
      )
      list(
        result = result,
        group_labels = as.character(groups),
        x = x, y = y
      )
    })

    print_fn <- function(){
      fit <- ttest_fit()
      print(fit$result)
    }

    table_fn <- function(){
      fit <- ttest_fit()
      r <- fit$result
      data.frame(
        Statistic = c(
          "t", "df", "p.value",
          paste0("mean.", fit$group_labels[1]),
          paste0("mean.", fit$group_labels[2]),
          "ci.lower", "ci.upper"
        ),
        Value = c(
          unname(r$statistic),
          unname(r$parameter),
          r$p.value,
          unname(r$estimate[1]),
          unname(r$estimate[2]),
          r$conf.int[1],
          r$conf.int[2]
        ),
        stringsAsFactors = FALSE
      )
    }

    plot_fn <- function(){
      fit <- ttest_fit()
      op <- par(mar = c(4.5, 4.5, 3, 1))
      on.exit(par(op), add = TRUE)
      boxplot(
        list(fit$x, fit$y),
        names = fit$group_labels,
        col = c("#8ecae6", "#ffb4a2"),
        border = "#1f3b5b",
        main = sprintf(
          "%s: p = %.4g",
          input$value_var, fit$result$p.value
        ),
        ylab = input$value_var,
        xlab = input$group_var
      )
      points(
        x = c(1, 2),
        y = c(mean(fit$x, na.rm = TRUE), mean(fit$y, na.rm = TRUE)),
        pch = 18, col = "#d62828", cex = 1.5
      )
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "t_test", plot_fn)
  })
}
