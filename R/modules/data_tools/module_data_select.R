parse_rename_pairs <- function(text){
  if (is.null(text) || !nzchar(trimws(text))) return(list())
  lines <- strsplit(text, "\n", fixed = TRUE)[[1]]
  lines <- trimws(lines)
  lines <- lines[nzchar(lines)]
  mapping <- list()
  for (line in lines) {
    parts <- strsplit(line, "=", fixed = TRUE)[[1]]
    if (length(parts) != 2) next
    old_name <- trimws(parts[1])
    new_name <- trimws(parts[2])
    if (nzchar(old_name) && nzchar(new_name)) {
      mapping[[old_name]] <- new_name
    }
  }
  mapping
}

data_tools_select_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      current <- input$keep_columns
      if (is.null(current)) current <- character()

      sync_multi_column_choices(
        session,
        df(),
        "keep_columns",
        selected = intersect(current, names(df()))
      )

      if (length(current) == 0) {
        updateSelectizeInput(
          session = session,
          inputId = "keep_columns",
          choices = names(df()),
          selected = names(df()),
          server = TRUE
        )
      }
    }, ignoreNULL = FALSE)

    selected <- eventReactive(input$apply_transform, {
      cols <- input$keep_columns
      validate(need(length(cols) >= 1, "Select at least one column to keep."))
      validate_required_columns(df(), cols)

      data <- df()[, cols, drop = FALSE]

      mapping <- parse_rename_pairs(input$rename_pairs)
      if (length(mapping) > 0) {
        for (old_name in names(mapping)) {
          hit <- which(names(data) == old_name)
          if (length(hit) == 1) {
            names(data)[hit] <- mapping[[old_name]]
          }
        }
      }
      data
    })

    bind_data_tools_outputs(output, input, selected, "selected_columns")
  })
}
