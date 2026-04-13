data_tools_summarize_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
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
          selected = numeric_cols,
          server = TRUE
        )
      }
    }, ignoreNULL = FALSE)

    summarized <- eventReactive(input$apply_transform, {
      group_cols <- input$group_columns
      value_cols <- input$value_columns
      agg <- input$agg_fun

      validate(need(length(group_cols) >= 1, "Select at least one group column."))

      if (identical(agg, "count")) {
        tab <- as.data.frame(
          table(df()[, group_cols, drop = FALSE], useNA = "ifany"),
          stringsAsFactors = FALSE
        )
        names(tab)[ncol(tab)] <- "n"
        return(tab)
      }

      validate(need(length(value_cols) >= 1, "Select at least one numeric value column."))
      validate_required_columns(df(), c(group_cols, value_cols))
      validate_numeric_columns(df(), value_cols)

      agg_fn <- match.fun(agg)
      data <- df()[, c(group_cols, value_cols), drop = FALSE]

      formula_rhs <- paste(
        vapply(group_cols, function(x) paste0("`", x, "`"), character(1)),
        collapse = " + "
      )
      formula_lhs <- if (length(value_cols) == 1) {
        paste0("`", value_cols, "`")
      } else {
        paste0("cbind(", paste(vapply(value_cols, function(x) paste0("`", x, "`"), character(1)), collapse = ", "), ")")
      }
      fml <- stats::as.formula(paste(formula_lhs, "~", formula_rhs))

      result <- stats::aggregate(
        fml,
        data = data,
        FUN = function(v) agg_fn(v, na.rm = TRUE),
        na.action = stats::na.pass
      )

      if (length(value_cols) > 1) {
        cbind_mat <- result[[length(group_cols) + 1]]
        result <- result[, seq_len(length(group_cols)), drop = FALSE]
        for (j in seq_along(value_cols)) {
          result[[value_cols[j]]] <- cbind_mat[, j]
        }
      }
      result
    })

    bind_data_tools_outputs(output, input, summarized, "summarized_data")
  })
}
