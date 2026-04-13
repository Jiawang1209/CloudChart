stats_chisq_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session,
        df(),
        c("row_var", "col_var"),
        selected_map = list(
          row_var = bgc_pick_column(input$row_var, discrete_cols[1]),
          col_var = bgc_pick_column(input$col_var, discrete_cols[2])
        )
      )
    }, ignoreNULL = FALSE)

    chisq_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$row_var), nzchar(input$col_var))
      validate(
        need(input$row_var != input$col_var,
             "Row and column variables must be different.")
      )
      validate_required_columns(df(), c(input$row_var, input$col_var))

      row_values <- df()[[input$row_var]]
      col_values <- df()[[input$col_var]]
      keep <- !is.na(row_values) & !is.na(col_values)

      tab <- table(
        factor(row_values[keep]),
        factor(col_values[keep])
      )

      validate(
        need(nrow(tab) >= 2 && ncol(tab) >= 2,
             "Chi-square test requires at least 2 rows and 2 columns in the contingency table."),
        need(sum(tab) >= 2,
             "Not enough observations after removing NAs.")
      )

      result <- suppressWarnings(chisq.test(
        tab,
        correct = identical(input$correct, "yes"),
        simulate.p.value = identical(input$simulate_p, "yes"),
        B = 2000
      ))
      list(result = result, table = tab)
    })

    print_fn <- function(){
      fit <- chisq_fit()
      cat("=== Contingency Table (observed) ===\n")
      print(fit$table)
      cat("\n=== Expected Counts ===\n")
      print(round(fit$result$expected, 3))
      cat("\n=== Chi-square Test ===\n")
      print(fit$result)
    }

    table_fn <- function(){
      fit <- chisq_fit()
      r <- fit$result
      df_val <- if (is.null(r$parameter)) NA_real_ else unname(r$parameter)
      data.frame(
        Statistic = c("X-squared", "df", "p.value", "n.total"),
        Value = c(
          unname(r$statistic),
          df_val,
          r$p.value,
          sum(fit$table)
        ),
        stringsAsFactors = FALSE
      )
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "chi_square")
  })
}
