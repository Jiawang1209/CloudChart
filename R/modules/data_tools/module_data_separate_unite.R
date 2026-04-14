data_tools_separate_unite_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      sync_column_choices(
        session, df(),
        c("separate_col"),
        selected_map = list(
          separate_col = bgc_pick_column(input$separate_col, names(df())[1])
        )
      )
      current <- input$unite_cols
      if (is.null(current)) current <- character()
      sync_multi_column_choices(
        session, df(), "unite_cols",
        selected = intersect(current, names(df()))
      )
    }, ignoreNULL = FALSE)

    transformed <- eventReactive(input$apply_transform, {
      data <- df()
      remove_source <- identical(input$remove_source, "yes")

      if (identical(input$operation, "separate")) {
        validate_required_columns(data, input$separate_col)
        new_cols <- trimws(strsplit(input$separate_into, ",", fixed = TRUE)[[1]])
        new_cols <- new_cols[nzchar(new_cols)]
        validate(need(length(new_cols) >= 2, "Provide at least two new column names."))

        parts <- strsplit(as.character(data[[input$separate_col]]),
                          input$separator, perl = TRUE)
        max_len <- length(new_cols)
        parts <- lapply(parts, function(v) {
          length(v) <- max_len
          v
        })
        split_df <- do.call(rbind, parts)
        split_df <- as.data.frame(split_df, stringsAsFactors = FALSE)
        names(split_df) <- new_cols

        result <- cbind(data, split_df)
        if (remove_source) result[[input$separate_col]] <- NULL
        result
      } else {
        validate(need(length(input$unite_cols) >= 2, "Pick at least two columns to unite."))
        validate(need(nzchar(input$unite_into), "Provide a new column name."))
        validate_required_columns(data, input$unite_cols)

        joined <- do.call(paste,
                          c(lapply(input$unite_cols, function(c) as.character(data[[c]])),
                            sep = input$unite_sep))
        data[[input$unite_into]] <- joined
        if (remove_source) data[, setdiff(names(data), input$unite_cols), drop = FALSE] else data
      }
    })

    bind_data_tools_outputs(output, input, transformed, "separate_unite")
  })
}
