data_tools_filter_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      sync_column_choices(
        session,
        df(),
        "filter_column",
        selected_map = list(
          filter_column = bgc_pick_column(input$filter_column, names(df())[1])
        )
      )
    }, ignoreNULL = FALSE)

    filtered <- eventReactive(input$apply_transform, {
      req(nzchar(input$filter_column))
      validate_required_columns(df(), input$filter_column)

      data <- df()
      col <- data[[input$filter_column]]
      op <- input$filter_operator
      raw <- input$filter_value

      if (op %in% c("is_na", "not_na")) {
        keep <- if (op == "is_na") is.na(col) else !is.na(col)
      } else if (op == "contains") {
        validate(need(nzchar(raw), "Enter a value for 'contains' filter."))
        keep <- grepl(
          raw,
          as.character(col),
          fixed = TRUE,
          ignore.case = identical(input$case_sensitive, "no")
        )
        keep[is.na(keep)] <- FALSE
      } else {
        validate(need(nzchar(raw), "Enter a value for the comparison filter."))
        compare_value <- if (is.numeric(col)) {
          num <- suppressWarnings(as.numeric(raw))
          validate(need(!is.na(num), "Value must be numeric for numeric columns."))
          num
        } else {
          raw
        }
        keep <- switch(
          op,
          eq  = col == compare_value,
          neq = col != compare_value,
          gt  = col > compare_value,
          gte = col >= compare_value,
          lt  = col < compare_value,
          lte = col <= compare_value
        )
        keep[is.na(keep)] <- FALSE
      }

      data[keep, , drop = FALSE]
    })

    bind_data_tools_outputs(output, input, filtered, "filtered_data")
  })
}
