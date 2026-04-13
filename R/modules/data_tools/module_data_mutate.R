data_tools_mutate_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      sync_column_choices(
        session,
        df(),
        "source_column",
        selected_map = list(
          source_column = bgc_pick_column(input$source_column, names(df())[1])
        )
      )
    }, ignoreNULL = FALSE)

    mutated <- eventReactive(input$apply_transform, {
      req(nzchar(input$source_column))
      validate_required_columns(df(), input$source_column)

      data <- df()
      source_values <- data[[input$source_column]]
      op <- input$operation
      on_error <- input$on_error

      apply_op <- function(x) {
        switch(
          op,
          as_numeric   = suppressWarnings(as.numeric(as.character(x))),
          as_character = as.character(x),
          as_factor    = as.factor(x),
          as_logical   = suppressWarnings(as.logical(x)),
          as_integer   = suppressWarnings(as.integer(x)),
          log          = log(as.numeric(x)),
          log2         = log2(as.numeric(x)),
          log10        = log10(as.numeric(x)),
          sqrt         = sqrt(as.numeric(x)),
          exp          = exp(as.numeric(x)),
          abs          = abs(as.numeric(x)),
          round        = round(as.numeric(x)),
          rank         = rank(as.numeric(x), na.last = "keep"),
          scale        = as.numeric(scale(as.numeric(x))),
          toupper      = toupper(as.character(x)),
          tolower      = tolower(as.character(x)),
          trimws       = trimws(as.character(x)),
          stop("Unknown operation: ", op)
        )
      }

      result <- if (identical(on_error, "stop")) {
        apply_op(source_values)
      } else {
        tryCatch(
          suppressWarnings(apply_op(source_values)),
          error = function(e) rep(NA, length(source_values))
        )
      }

      target <- if (nzchar(input$new_column)) input$new_column else input$source_column
      data[[target]] <- result
      data
    })

    bind_data_tools_outputs(output, input, mutated, "mutated_data")
  })
}
