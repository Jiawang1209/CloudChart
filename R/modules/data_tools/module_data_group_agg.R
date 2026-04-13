data_tools_group_agg_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols  <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      current_groups <- input$group_columns
      if (is.null(current_groups)) current_groups <- character()
      current_values <- input$value_columns
      if (is.null(current_values)) current_values <- character()

      sync_multi_column_choices(
        session,
        df(),
        "group_columns",
        selected = intersect(current_groups, names(df()))
      )
      sync_multi_column_choices(
        session,
        df(),
        "value_columns",
        selected = intersect(current_values, numeric_cols)
      )

      if (length(current_groups) == 0 && length(discrete_cols) > 0) {
        updateSelectizeInput(
          session = session,
          inputId = "group_columns",
          choices = names(df()),
          selected = discrete_cols[1],
          server = TRUE
        )
      }
      if (length(current_values) == 0 && length(numeric_cols) > 0) {
        updateSelectizeInput(
          session = session,
          inputId = "value_columns",
          choices = names(df()),
          selected = numeric_cols[1],
          server = TRUE
        )
      }
    }, ignoreNULL = FALSE)

    aggregated <- eventReactive(input$apply_transform, {
      group_cols <- input$group_columns
      value_cols <- input$value_columns
      fns        <- input$agg_functions

      validate(
        need(length(group_cols) >= 1, "Select at least one group column."),
        need(length(value_cols) >= 1, "Select at least one numeric value column."),
        need(length(fns) >= 1,        "Select at least one aggregation function.")
      )
      validate_required_columns(df(), c(group_cols, value_cols))
      validate_numeric_columns(df(), value_cols)

      data <- df()[, c(group_cols, value_cols), drop = FALSE]
      group_key <- do.call(paste, c(lapply(group_cols, function(g) data[[g]]), sep = "\u0001"))
      split_idx <- split(seq_len(nrow(data)), group_key)

      agg_fn <- function(fn_name, x) {
        switch(
          fn_name,
          n      = length(x),
          mean   = mean(x,   na.rm = TRUE),
          median = stats::median(x, na.rm = TRUE),
          sum    = sum(x,    na.rm = TRUE),
          sd     = stats::sd(x,  na.rm = TRUE),
          var    = stats::var(x, na.rm = TRUE),
          min    = suppressWarnings(min(x, na.rm = TRUE)),
          max    = suppressWarnings(max(x, na.rm = TRUE)),
          NA_real_
        )
      }

      rows <- lapply(names(split_idx), function(key) {
        idx <- split_idx[[key]]
        first_row <- data[idx[1], group_cols, drop = FALSE]
        out <- first_row
        for (vc in value_cols) {
          vals <- data[[vc]][idx]
          for (fn in fns) {
            col_name <- paste0(vc, "_", fn)
            out[[col_name]] <- agg_fn(fn, vals)
          }
        }
        out
      })

      result <- do.call(rbind, rows)
      rownames(result) <- NULL
      result
    })

    bind_data_tools_outputs(output, input, aggregated, "grouped_aggregated")
  })
}
