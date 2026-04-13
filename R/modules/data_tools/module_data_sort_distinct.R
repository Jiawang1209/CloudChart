data_tools_sort_distinct_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      current_sort <- input$sort_columns
      if (is.null(current_sort)) current_sort <- character()
      sync_multi_column_choices(
        session,
        df(),
        "sort_columns",
        selected = intersect(current_sort, names(df()))
      )

      current_distinct <- input$distinct_columns
      if (is.null(current_distinct)) current_distinct <- character()
      sync_multi_column_choices(
        session,
        df(),
        "distinct_columns",
        selected = intersect(current_distinct, names(df()))
      )
    }, ignoreNULL = FALSE)

    transformed <- eventReactive(input$apply_transform, {
      data <- df()

      sort_cols <- input$sort_columns
      if (!is.null(sort_cols) && length(sort_cols) > 0) {
        validate_required_columns(data, sort_cols)
        descending <- identical(input$sort_order, "desc")
        order_args <- lapply(sort_cols, function(col) {
          if (descending) -xtfrm(data[[col]]) else xtfrm(data[[col]])
        })
        data <- data[do.call(order, order_args), , drop = FALSE]
      }

      mode <- input$distinct_mode
      if (identical(mode, "all")) {
        data <- data[!duplicated(data), , drop = FALSE]
      } else if (identical(mode, "selected")) {
        distinct_cols <- input$distinct_columns
        validate(need(length(distinct_cols) >= 1,
                      "Select at least one column for 'Distinct on selected columns'."))
        validate_required_columns(data, distinct_cols)
        data <- data[!duplicated(data[, distinct_cols, drop = FALSE]), , drop = FALSE]
      }

      data
    })

    bind_data_tools_outputs(output, input, transformed, "sorted_distinct")
  })
}
