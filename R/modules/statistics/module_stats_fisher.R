stats_fisher_Server <- function(id){
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

    fisher_fit <- eventReactive(input$run_analysis, {
      req(nzchar(input$row_var), nzchar(input$col_var))
      validate(need(input$row_var != input$col_var,
                    "Row and column variables must be different."))
      validate_required_columns(df(), c(input$row_var, input$col_var))

      row_values <- df()[[input$row_var]]
      col_values <- df()[[input$col_var]]
      keep <- !is.na(row_values) & !is.na(col_values)
      tab <- table(factor(row_values[keep]), factor(col_values[keep]))

      validate(
        need(nrow(tab) >= 2 && ncol(tab) >= 2,
             "Fisher's test requires at least 2 rows and 2 columns in the contingency table.")
      )

      is_2x2 <- nrow(tab) == 2 && ncol(tab) == 2
      result <- if (is_2x2) {
        fisher.test(
          tab,
          alternative = input$alternative,
          conf.level = input$conf_level
        )
      } else {
        suppressWarnings(fisher.test(tab, simulate.p.value = TRUE, B = 10000))
      }
      list(result = result, table = tab, is_2x2 = is_2x2)
    })

    print_fn <- function(){
      fit <- fisher_fit()
      cat("=== Contingency Table ===\n")
      print(fit$table)
      cat("\n=== Fisher's Exact Test ===\n")
      if (!fit$is_2x2) {
        cat("Table is not 2x2; p-value computed via Monte Carlo (B=10000).\n")
      }
      print(fit$result)
    }

    table_fn <- function(){
      fit <- fisher_fit()
      r <- fit$result
      if (fit$is_2x2) {
        data.frame(
          Statistic = c("p.value", "odds.ratio", "ci.lower", "ci.upper"),
          Value = c(
            r$p.value,
            unname(r$estimate),
            r$conf.int[1],
            r$conf.int[2]
          ),
          stringsAsFactors = FALSE
        )
      } else {
        data.frame(
          Statistic = c("p.value (simulated)", "n.total"),
          Value = c(r$p.value, sum(fit$table)),
          stringsAsFactors = FALSE
        )
      }
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "fisher_exact")
  })
}
