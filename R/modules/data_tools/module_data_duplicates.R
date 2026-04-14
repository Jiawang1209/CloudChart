data_tools_duplicates_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      current <- input$key_cols
      if (is.null(current)) current <- character()
      sync_multi_column_choices(
        session, df(), "key_cols",
        selected = intersect(current, names(df()))
      )
    }, ignoreNULL = FALSE)

    transformed <- eventReactive(input$apply_transform, {
      data <- df()
      mode <- input$key_mode

      key_df <- if (identical(mode, "all")) {
        data
      } else {
        validate(need(length(input$key_cols) >= 1,
                      "Pick at least one key column or switch to 'All columns'."))
        validate_required_columns(data, input$key_cols)
        data[, input$key_cols, drop = FALSE]
      }

      include_first <- identical(input$include_first, "yes")
      dup_forward  <- duplicated(key_df)
      dup_backward <- duplicated(key_df, fromLast = TRUE)
      is_dup <- if (include_first) (dup_forward | dup_backward) else dup_forward

      switch(input$result_mode,
        duplicates = data[is_dup, , drop = FALSE],
        drop       = data[!dup_forward, , drop = FALSE],
        flag       = {
          flag_name <- if (nzchar(input$flag_col)) input$flag_col else "is_duplicate"
          data[[flag_name]] <- is_dup
          data
        }
      )
    })

    bind_data_tools_outputs(output, input, transformed, "duplicates")
  })
}
