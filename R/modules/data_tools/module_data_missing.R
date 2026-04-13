data_tools_missing_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      current <- input$target_columns
      if (is.null(current)) current <- character()
      sync_multi_column_choices(
        session,
        df(),
        "target_columns",
        selected = intersect(current, names(df()))
      )
    }, ignoreNULL = FALSE)

    transformed <- eventReactive(input$apply_transform, {
      data <- df()
      cols <- input$target_columns
      if (is.null(cols) || length(cols) == 0) {
        cols <- names(data)
      }
      validate_required_columns(data, cols)

      strategy <- input$strategy

      if (strategy == "drop_any") {
        keep <- complete.cases(data[, cols, drop = FALSE])
        return(data[keep, , drop = FALSE])
      }

      if (strategy == "drop_all") {
        sub <- data[, cols, drop = FALSE]
        keep <- rowSums(is.na(sub)) < length(cols)
        return(data[keep, , drop = FALSE])
      }

      if (strategy == "custom") {
        raw <- input$custom_value
        validate(need(nzchar(raw), "Enter a custom fill value."))
        for (col in cols) {
          fill_value <- if (is.numeric(data[[col]])) {
            num <- suppressWarnings(as.numeric(raw))
            validate(need(!is.na(num), paste0("Custom value must be numeric for column '", col, "'.")))
            num
          } else {
            raw
          }
          data[[col]][is.na(data[[col]])] <- fill_value
        }
        return(data)
      }

      for (col in cols) {
        if (!is.numeric(data[[col]])) next
        values <- data[[col]]
        fill_value <- switch(
          strategy,
          mean = mean(values, na.rm = TRUE),
          median = stats::median(values, na.rm = TRUE),
          zero = 0
        )
        values[is.na(values)] <- fill_value
        data[[col]] <- values
      }
      data
    })

    bind_data_tools_outputs(output, input, transformed, "missing_handled")
  })
}
