data_tools_pivot_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      sync_column_choices(
        session,
        df(),
        c("names_from", "values_from"),
        selected_map = list(
          names_from = bgc_pick_column(input$names_from, names(df())[1]),
          values_from = bgc_pick_column(input$values_from, bgc_numeric_columns(df())[1])
        )
      )

      current_pivot <- input$pivot_cols
      if (is.null(current_pivot)) current_pivot <- character()
      sync_multi_column_choices(
        session,
        df(),
        "pivot_cols",
        selected = intersect(current_pivot, names(df()))
      )
    }, ignoreNULL = FALSE)

    transformed <- eventReactive(input$apply_transform, {
      data <- df()
      if (identical(input$direction, "wider")) {
        validate(
          need(nzchar(input$names_from), "Select a names_from column."),
          need(nzchar(input$values_from), "Select a values_from column.")
        )
        validate_required_columns(data, c(input$names_from, input$values_from))
        tidyr::pivot_wider(
          data,
          names_from = dplyr::all_of(input$names_from),
          values_from = dplyr::all_of(input$values_from)
        )
      } else {
        pivot_cols <- input$pivot_cols
        validate(need(length(pivot_cols) >= 1, "Select at least one column to pivot longer."))
        validate_required_columns(data, pivot_cols)
        names_to <- if (nzchar(input$names_to)) input$names_to else "name"
        values_to <- if (nzchar(input$values_to)) input$values_to else "value"
        tidyr::pivot_longer(
          data,
          cols = dplyr::all_of(pivot_cols),
          names_to = names_to,
          values_to = values_to
        )
      }
    })

    bind_data_tools_outputs(output, input, transformed, "pivoted_data")
  })
}
