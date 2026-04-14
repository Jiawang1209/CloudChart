data_tools_date_parse_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      sync_column_choices(
        session, df(),
        c("date_col"),
        selected_map = list(
          date_col = bgc_pick_column(input$date_col,
                                     bgc_first_match(c("date","Date","timestamp","time"), names(df())),
                                     names(df())[1])
        )
      )
    }, ignoreNULL = FALSE)

    transformed <- eventReactive(input$apply_transform, {
      validate_required_columns(df(), input$date_col)
      validate(need(nzchar(input$new_col), "Provide a parsed column name."))

      data <- df()
      raw <- as.character(data[[input$date_col]])
      parsed <- as.Date(raw, format = input$date_format)

      n_failed <- sum(is.na(parsed) & !is.na(raw) & nzchar(raw))
      if (n_failed > 0) {
        showNotification(
          sprintf("%d value(s) could not be parsed with format '%s'.", n_failed, input$date_format),
          type = "warning"
        )
      }

      data[[input$new_col]] <- parsed
      parts <- input$extract_parts %||% character()

      if ("year" %in% parts)    data[[paste0(input$new_col, "_year")]]    <- as.integer(format(parsed, "%Y"))
      if ("quarter" %in% parts) data[[paste0(input$new_col, "_quarter")]] <- ((as.integer(format(parsed, "%m")) - 1) %/% 3 + 1)
      if ("month" %in% parts)   data[[paste0(input$new_col, "_month")]]   <- as.integer(format(parsed, "%m"))
      if ("day" %in% parts)     data[[paste0(input$new_col, "_day")]]     <- as.integer(format(parsed, "%d"))
      if ("weekday" %in% parts) data[[paste0(input$new_col, "_weekday")]] <- weekdays(parsed)
      if ("week" %in% parts)    data[[paste0(input$new_col, "_week")]]    <- as.integer(format(parsed, "%V"))

      data
    })

    bind_data_tools_outputs(output, input, transformed, "date_parsed")
  })
}
