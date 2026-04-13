stats_correlation_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      current <- input$numeric_columns
      if (is.null(current)) current <- character()

      sync_multi_column_choices(
        session,
        df(),
        "numeric_columns",
        selected = intersect(current, numeric_cols)
      )

      if (length(current) == 0 && length(numeric_cols) >= 2) {
        updateSelectizeInput(
          session = session,
          inputId = "numeric_columns",
          choices = names(df()),
          selected = numeric_cols,
          server = TRUE
        )
      }
    }, ignoreNULL = FALSE)

    pairs_result <- eventReactive(input$run_analysis, {
      cols <- input$numeric_columns
      validate(need(length(cols) >= 2, "Select at least two numeric columns."))
      validate_required_columns(df(), cols)
      validate_numeric_columns(df(), cols)

      data_subset <- df()[, cols, drop = FALSE]
      combos <- utils::combn(cols, 2, simplify = FALSE)
      rows <- lapply(combos, function(pair) {
        x <- data_subset[[pair[1]]]
        y <- data_subset[[pair[2]]]
        ct <- suppressWarnings(cor.test(x, y, method = input$cor_method))
        data.frame(
          Var1 = pair[1],
          Var2 = pair[2],
          r = unname(ct$estimate),
          p.value = ct$p.value,
          n = sum(complete.cases(x, y)),
          stringsAsFactors = FALSE
        )
      })
      tab <- do.call(rbind, rows)
      if (!identical(input$adjust_method, "none")) {
        tab$p.adj <- p.adjust(tab$p.value, method = input$adjust_method)
      }
      tab
    })

    print_fn <- function(){
      tab <- pairs_result()
      cat(sprintf("Correlation method: %s\n", input$cor_method))
      cat(sprintf("Pairs computed: %d\n", nrow(tab)))
      if ("p.adj" %in% names(tab)) {
        cat(sprintf("p-value adjust method: %s\n", input$adjust_method))
      }
      cat("\n")
      print(tab, row.names = FALSE)
    }

    table_fn <- function(){
      pairs_result()
    }

    bind_stats_outputs(output, input, print_fn, table_fn, "correlation")
  })
}
