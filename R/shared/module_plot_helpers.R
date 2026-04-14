sanitize_uploaded_table <- function(data, drop_all_na_cols = TRUE) {
  if (!is.data.frame(data)) {
    stop("sanitize_uploaded_table expects a data.frame.", call. = FALSE)
  }

  if (ncol(data) == 0L) {
    return(data)
  }

  nm <- as.character(names(data))
  nm[is.na(nm)] <- ""
  nm <- trimws(nm)

  blank_idx <- which(!nzchar(nm))
  if (length(blank_idx) > 0L) {
    nm[blank_idx] <- paste0("V", blank_idx)
  }

  if (anyDuplicated(nm) > 0L) {
    nm <- make.unique(nm, sep = "_")
  }

  names(data) <- nm

  if (isTRUE(drop_all_na_cols) && ncol(data) > 0L) {
    keep <- vapply(
      data,
      function(col) !all(is.na(col)),
      logical(1)
    )
    data <- data[, keep, drop = FALSE]
  }

  data
}

read_uploaded_table <- function(file_upload, header, separator, quote, row_names = FALSE) {
  tryCatch(
    {
      ext <- tolower(tools::file_ext(file_upload$name))
      auto <- identical(separator, "auto")
      is_xlsx <- ext %in% c("xlsx", "xls") || identical(separator, "xlsx2")

      data <- if (is_xlsx) {
        raw <- as.data.frame(
          readxl::read_excel(path = file_upload$datapath),
          check.names = FALSE
        )

        if (isTRUE(row_names)) {
          if (ncol(raw) < 2) {
            stop("The uploaded Excel file must contain at least two columns when the first column is used as row names.")
          }
          rownames(raw) <- raw[[1]]
          raw <- raw[-1]
        }

        raw
      } else {
        sep <- if (auto) {
          switch(ext,
            tsv = "\t",
            tab = "\t",
            txt = "\t",
            ","
          )
        } else {
          separator
        }

        read.csv(
          file = file_upload$datapath,
          header = header,
          sep = sep,
          quote = quote,
          row.names = if (isTRUE(row_names)) 1 else NULL,
          check.names = FALSE
        )
      }

      sanitize_uploaded_table(data)
    },
    error = function(e) {
      stop(paste("Failed to read uploaded file:", conditionMessage(e)), call. = FALSE)
    }
  )
}

bgc_advanced_options <- function(...) {
  tags$details(
    class = "bgc-advanced-options",
    tags$summary("Advanced Options"),
    tags$div(class = "bgc-advanced-options__body", ...)
  )
}

bgc_preview_datatable <- function(data, digits = 4, page_length = 10) {
  if (!is.data.frame(data)) {
    data <- as.data.frame(data, stringsAsFactors = FALSE)
  }

  data <- sanitize_uploaded_table(data, drop_all_na_cols = FALSE)

  dt <- DT::datatable(
    data,
    rownames = FALSE,
    class    = "compact stripe hover",
    options  = list(
      pageLength = page_length,
      lengthMenu = c(5, 10, 25, 50, 100),
      scrollX    = TRUE,
      dom        = "lftip"
    )
  )

  numeric_cols <- names(data)[vapply(data, is.numeric, logical(1))]
  if (length(numeric_cols) > 0L) {
    dt <- DT::formatSignif(dt, columns = numeric_cols, digits = digits)
  }

  dt
}

bgc_preview_error_dt <- function(message) {
  DT::datatable(
    data.frame(Error = message),
    rownames = FALSE,
    options  = list(dom = "t", ordering = FALSE)
  )
}

bgc_column_select <- function(id, input_id, label, selected = "") {
  selectizeInput(
    inputId = NS(id, input_id),
    label = label,
    choices = "",
    selected = selected,
    options = list(
      placeholder = "Select a column",
      create = TRUE
    )
  )
}

bgc_multi_column_select <- function(id, input_id, label, selected = character()) {
  selectizeInput(
    inputId = NS(id, input_id),
    label = label,
    choices = "",
    selected = selected,
    multiple = TRUE,
    options = list(
      placeholder = "Select one or more columns"
    )
  )
}

sync_column_choices <- function(session, data, field_ids, selected_map = list(), extra_choices = character()) {
  choices <- unique(c("", names(data), extra_choices))

  for (field_id in field_ids) {
    selected_value <- selected_map[[field_id]]

    if (is.null(selected_value)) {
      selected_value <- ""
    }

    if (!selected_value %in% choices) {
      selected_value <- ""
    }

    updateSelectizeInput(
      session = session,
      inputId = field_id,
      choices = choices,
      selected = selected_value,
      server = TRUE
    )
  }
}

sync_multi_column_choices <- function(session, data, field_id, selected = character(), extra_choices = character()) {
  choices <- unique(c(names(data), extra_choices))
  selected <- selected[selected %in% choices]

  updateSelectizeInput(
    session = session,
    inputId = field_id,
    choices = choices,
    selected = selected,
    server = TRUE
  )
}

bgc_numeric_columns <- function(data) {
  names(data)[vapply(data, is.numeric, logical(1))]
}

bgc_discrete_columns <- function(data) {
  names(data)[!vapply(data, is.numeric, logical(1))]
}

bgc_first_match <- function(candidates, pool) {
  match_value <- candidates[candidates %in% pool][1]

  if (is.na(match_value) || length(match_value) == 0) {
    return("")
  }

  match_value
}

bgc_pick_column <- function(preferred = character(), ...) {
  candidates <- c(preferred, unlist(list(...)))
  for (value in candidates) {
    if (!is.null(value) && length(value) > 0 && !is.na(value) && nzchar(value)) {
      return(value)
    }
  }

  ""
}

bgc_data_summary <- function(data) {
  numeric_cols <- bgc_numeric_columns(data)
  discrete_cols <- bgc_discrete_columns(data)
  missing_cells <- sum(is.na(data))

  recommended_x <- bgc_pick_column(discrete_cols[1], numeric_cols[1])
  recommended_y <- bgc_pick_column(numeric_cols[1], discrete_cols[1])
  recommended_group <- bgc_pick_column(discrete_cols[2], discrete_cols[1])

  list(
    rows = nrow(data),
    columns = ncol(data),
    numeric_count = length(numeric_cols),
    discrete_count = length(discrete_cols),
    missing_cells = missing_cells,
    numeric_cols = numeric_cols,
    discrete_cols = discrete_cols,
    recommended_x = recommended_x,
    recommended_y = recommended_y,
    recommended_group = recommended_group
  )
}

bgc_default_metadata_columns <- function(data) {
  bgc_discrete_columns(data)
}

bgc_analysis_input <- function(data, metadata_columns = character()) {
  metadata_columns <- intersect(metadata_columns, names(data))
  feature_columns <- setdiff(names(data), metadata_columns)

  validate(
    need(length(feature_columns) >= 2, "Select at least two feature columns for the analysis."),
    need(
      all(vapply(data[feature_columns], is.numeric, logical(1))),
      paste0(
        "Feature columns must be numeric: ",
        paste(feature_columns[!vapply(data[feature_columns], is.numeric, logical(1))], collapse = ", ")
      )
    )
  )

  list(
    feature_data = data[feature_columns],
    metadata_data = data[metadata_columns],
    feature_columns = feature_columns,
    metadata_columns = metadata_columns
  )
}

uploaded_table_reactive <- function(input, row_names = FALSE) {
  eventReactive(input$submit_file, {
    req(input$file_upload)
    read_uploaded_table(
      file_upload = input$file_upload,
      header = input$file_header,
      separator = input$file_separator,
      quote = input$file_quote,
      row_names = row_names
    )
  })
}

non_empty_inputs <- function(...) {
  values <- list(...)
  Filter(function(x) !is.null(x) && nzchar(x), values)
}

validate_required_columns <- function(data, columns, data_label = "uploaded data") {
  required_columns <- unique(unlist(non_empty_inputs(columns), use.names = FALSE))
  missing_columns <- setdiff(required_columns, names(data))

  validate(
    need(
      length(missing_columns) == 0,
      paste0(
        "Missing column(s) in ",
        data_label,
        ": ",
        paste(missing_columns, collapse = ", ")
      )
    )
  )
}

validate_numeric_columns <- function(data, columns, data_label = "uploaded data") {
  required_columns <- unique(unlist(non_empty_inputs(columns), use.names = FALSE))
  non_numeric_columns <- required_columns[!vapply(data[required_columns], is.numeric, logical(1))]

  validate(
    need(
      length(non_numeric_columns) == 0,
      paste0(
        "These columns must be numeric in ",
        data_label,
        ": ",
        paste(non_numeric_columns, collapse = ", ")
      )
    )
  )
}

validate_shape_range <- function(input) {
  if (is.null(input$shape_variable) || !nzchar(input$shape_variable)) {
    return(invisible(TRUE))
  }

  shape_values <- input$shape_value
  is_valid <- length(shape_values) == 2 &&
    all(!is.na(shape_values)) &&
    shape_values[1] <= shape_values[2]

  validate(
    need(
      is_valid,
      "Set a valid shape range before plotting when shape_variable is used."
    )
  )
}

validate_matrix_input <- function(data, min_feature_columns = 2, data_label = "uploaded data") {
  validate(
    need(
      ncol(data) > min_feature_columns - 1,
      paste0(data_label, " must contain at least ", min_feature_columns, " feature columns.")
    )
  )
}

apply_plot_limits <- function(p, input) {
  if (!is.null(input$x_limite[1])) {
    p <- p + xlim(input$x_limite[1], input$x_limite[2])
  }

  if (!is.null(input$y_limite[1])) {
    p <- p + ylim(input$y_limite[1], input$y_limite[2])
  }

  p
}

bgc_default <- function(value, fallback) {
  if (is.null(value)) return(fallback)
  if (length(value) == 0L) return(fallback)
  if (is.character(value) && !nzchar(value)) return(fallback)
  value
}

bgc_plot_device <- function(format, file, width, height) {
  fmt <- toupper(bgc_default(format, "PDF"))
  if (fmt == "PNG") {
    grDevices::png(filename = file, width = width, height = height, units = "in", res = 300)
  } else if (fmt == "SVG") {
    grDevices::svg(filename = file, width = width, height = height)
  } else {
    grDevices::pdf(file = file, width = width, height = height)
  }
}

bgc_plot_extension <- function(format) {
  switch(toupper(bgc_default(format, "PDF")), PNG = "png", SVG = "svg", "pdf")
}

bgc_serialize_inputs <- function(input) {
  raw <- tryCatch(
    shiny::reactiveValuesToList(input, all.names = FALSE),
    error = function(e) list()
  )

  drop_prefixes <- c("file_output", "file_upload")
  drop_exact <- c(
    "submit_file", "Plot", "Download", "DownloadParams", "DownloadData",
    "build_interactive_plot", "Format", "file_header", "file_separator", "file_quote"
  )

  keep <- list()
  for (nm in sort(names(raw))) {
    if (startsWith(nm, ".")) next
    if (nm %in% drop_exact) next
    if (any(vapply(drop_prefixes, function(p) startsWith(nm, p), logical(1)))) next
    v <- raw[[nm]]
    if (is.null(v)) next
    if (!is.atomic(v)) next
    if (length(v) == 0L || length(v) > 64L) next
    if (is.list(v)) next
    keep[[nm]] <- as.vector(v)
  }
  keep
}

bind_plot_outputs <- function(output, input, plot_reactive, vals, filename_prefix, data_fn = NULL) {
  output$plotOutput <- renderPlot({
    plot_reactive()
  })

  output$Download <- downloadHandler(
    filename = function() {
      paste0(filename_prefix, "_", Sys.Date(), ".", bgc_plot_extension(input$Format))
    },
    content = function(file) {
      req(!is.null(vals$p))
      bgc_plot_device(input$Format, file, input$Width, input$Height)
      on.exit(grDevices::dev.off(), add = TRUE)
      print(vals$p)
    }
  )

  output$DownloadParams <- downloadHandler(
    filename = function() {
      paste0(filename_prefix, "_params_", Sys.Date(), ".yaml")
    },
    content = function(file) {
      snapshot <- bgc_serialize_inputs(input)
      header <- paste0("# CloudChart parameters for ", filename_prefix,
                       " (", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), ")\n")
      body <- if (length(snapshot) > 0L) yaml::as.yaml(snapshot) else "# no parameters captured\n"
      writeLines(c(header, body), file)
    }
  )

  output$DownloadData <- downloadHandler(
    filename = function() {
      paste0(filename_prefix, "_data_", Sys.Date(), ".csv")
    },
    content = function(file) {
      df <- if (is.function(data_fn)) {
        tryCatch(data_fn(), error = function(e) NULL)
      } else {
        NULL
      }
      if (is.null(df) || !is.data.frame(df) || nrow(df) == 0L) {
        writeLines("# no processed data available for this module", file)
      } else {
        utils::write.csv(df, file, row.names = FALSE)
      }
    }
  )

  interactive_plot_reactive <- eventReactive(input$build_interactive_plot, {
    req(!is.null(vals$p))
    plotly::ggplotly(vals$p)
  })

  output$interactive_plot <- plotly::renderPlotly({
    validate(
      need(
        !is.null(vals$p),
        "Generate the static plot before building the interactive view."
      ),
      need(
        input$build_interactive_plot > 0,
        "Click 'Build Interactive Plot' to render the interactive view."
      )
    )
    interactive_plot_reactive()
  })
}

add_standard_plot_labels <- function(p, input, x_label = input$x_axis_Title, y_label = input$y_axis_Title) {
  p +
    labs(
      x = x_label,
      y = y_label,
      title = input$plot_title,
      subtitle = input$plot_subtitle
    ) +
    get(input$theme_choose)() +
    theme(text = element_text(size = input$label_size))
}

apply_fill_scales <- function(p, input) {
  if (input$discrete_fill_choose != "") {
    p <- p + get(input$discrete_fill_choose)()
  }

  if (input$continuous_fill_choose != "") {
    p <- p + scale_fill_material(input$continuous_fill_choose)
  }

  p
}

apply_color_scales <- function(p, input, palette_input = "discrete_color_choose") {
  palette_name <- input[[palette_input]]

  if (!is.null(palette_name) && palette_name != "") {
    p <- p + get(palette_name)()
  }

  p
}
