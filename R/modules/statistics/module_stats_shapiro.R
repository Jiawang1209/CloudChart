stats_shapiro_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      current <- input$target_columns
      if (is.null(current)) current <- character()
      sync_multi_column_choices(
        session,
        df(),
        "target_columns",
        selected = intersect(current, numeric_cols)
      )

      sync_column_choices(
        session,
        df(),
        "group_var",
        selected_map = list(
          group_var = bgc_pick_column(input$group_var, "")
        )
      )

      if (length(current) == 0 && length(numeric_cols) >= 1) {
        updateSelectizeInput(
          session = session,
          inputId = "target_columns",
          choices = names(df()),
          selected = numeric_cols[1],
          server = TRUE
        )
      }
    }, ignoreNULL = FALSE)

    shapiro_fit <- eventReactive(input$run_analysis, {
      cols <- input$target_columns
      validate(need(length(cols) >= 1, "Select at least one numeric column."))
      validate_required_columns(df(), cols)
      validate_numeric_columns(df(), cols)

      group_var <- input$group_var
      use_group <- !is.null(group_var) && nzchar(group_var)
      if (use_group) validate_required_columns(df(), group_var)

      rows <- list()
      for (col in cols) {
        if (use_group) {
          groups <- split(df()[[col]], df()[[group_var]])
          for (g_name in names(groups)) {
            vals <- groups[[g_name]]
            vals <- vals[!is.na(vals)]
            if (length(vals) >= 3 && length(vals) <= 5000) {
              r <- shapiro.test(vals)
              rows[[length(rows) + 1]] <- data.frame(
                Column = col,
                Group = g_name,
                n = length(vals),
                W = unname(r$statistic),
                p.value = r$p.value,
                normal = r$p.value > input$alpha,
                stringsAsFactors = FALSE
              )
            }
          }
        } else {
          vals <- df()[[col]]
          vals <- vals[!is.na(vals)]
          validate(
            need(length(vals) >= 3 && length(vals) <= 5000,
                 paste0("shapiro.test requires 3 to 5000 non-missing values for '", col, "'."))
          )
          r <- shapiro.test(vals)
          rows[[length(rows) + 1]] <- data.frame(
            Column = col,
            Group = "(all)",
            n = length(vals),
            W = unname(r$statistic),
            p.value = r$p.value,
            normal = r$p.value > input$alpha,
            stringsAsFactors = FALSE
          )
        }
      }
      validate(need(length(rows) > 0, "No eligible data for Shapiro-Wilk test."))
      do.call(rbind, rows)
    })

    print_fn <- function(){
      tab <- shapiro_fit()
      cat(sprintf("Shapiro-Wilk Normality Test (alpha = %.2f)\n", input$alpha))
      cat(sprintf("'normal' = TRUE means p > alpha (fail to reject normality).\n\n"))
      print(tab, row.names = FALSE)
    }

    table_fn <- function(){
      shapiro_fit()
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "shapiro_wilk")
  })
}
