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

# --- Shared tab shell ---------------------------------------------------------
# The "Example Data" and "Data & Parameters" tab panels are identical across
# every plot / stats / data_tools body. Build them once here so all three
# shells (basic_advance_plot_body / basic_stats_body / basic_data_tools_body)
# stay in lockstep when we tweak the upload widget, summary layout, or
# parameter region.
bgc_example_data_tab_panel <- function(inputid) {
  tabPanel(
    title = "Example Data",
    fluidPage(
      fluidRow(
        column(
          width = 12,
          align = "center",
          show_example_data_UI(id = inputid)
        )
      )
    )
  )
}

bgc_data_params_tab_panel <- function(inputid, fun) {
  tabPanel(
    title = "Data & Parameters",
    fluidPage(
      fluidRow(
        column(width = 3, file_upload_UI(id = inputid)),
        column(width = 9, file_upload_show_UI(id = inputid))
      )
    ),
    tags$hr(),
    fluidPage(
      get(fun)(inputid)
    )
  )
}

# Assemble the shared bs4TabCard shell. `result_panels` is a list of
# `tabPanel(...)` entries rendered after the shared Example Data /
# Data & Parameters tabs (e.g. "Plot" + "Interactive" for plots,
# "Results" for stats, "Result" for data_tools).
bgc_tabcard_shell <- function(inputid, fun, result_panels) {
  panels <- c(
    list(
      bgc_example_data_tab_panel(inputid),
      bgc_data_params_tab_panel(inputid, fun)
    ),
    result_panels
  )
  fluidPage(
    do.call(
      bs4TabCard,
      c(list(width = 12, type = "pills"), panels)
    )
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

bgc_session_upload_cache <- function(session = shiny::getDefaultReactiveDomain()) {
  if (is.null(session)) return(shiny::reactiveVal(NULL))

  root <- tryCatch(session$rootScope(), error = function(e) session)
  if (is.null(root)) root <- session

  if (is.null(root$userData)) {
    root$userData <- new.env(parent = emptyenv())
  }
  if (is.null(root$userData$bgc_upload_rv)) {
    root$userData$bgc_upload_rv <- shiny::reactiveVal(NULL)
  }
  root$userData$bgc_upload_rv
}

uploaded_table_reactive <- function(input, row_names = FALSE,
                                    session = shiny::getDefaultReactiveDomain()) {
  cache_rv <- bgc_session_upload_cache(session)

  shiny::observeEvent(input$submit_file, {
    shiny::req(input$file_upload)
    fu <- input$file_upload

    parsed <- shiny::withProgress(
      message = sprintf("Reading %s", fu$name),
      value   = 0.1,
      {
        shiny::incProgress(0.3, detail = "parsing")
        res <- tryCatch(
          read_uploaded_table(
            file_upload = fu,
            header      = input$file_header,
            separator   = input$file_separator,
            quote       = input$file_quote,
            row_names   = row_names
          ),
          error = function(e) {
            shiny::showNotification(
              paste("Upload failed:", conditionMessage(e)),
              type = "error", duration = 8
            )
            NULL
          }
        )
        shiny::setProgress(value = 1, detail = "done")
        res
      }
    )

    if (is.null(parsed)) return(NULL)

    cache_rv(list(
      name      = fu$name,
      datapath  = fu$datapath,
      header    = input$file_header,
      separator = input$file_separator,
      quote     = input$file_quote,
      data      = parsed,
      row_names = isTRUE(row_names),
      timestamp = Sys.time()
    ))
  })

  shiny::reactive({
    cache <- cache_rv()
    shiny::validate(shiny::need(
      !is.null(cache),
      "Upload a file and click 'Submit File!' to view the data."
    ))

    if (identical(cache$row_names, isTRUE(row_names))) {
      return(cache$data)
    }

    bgc_cached_compute(
      key = list("upload_reparse", cache$datapath, cache$header,
                 cache$separator, cache$quote, isTRUE(row_names)),
      compute = function() {
        read_uploaded_table(
          file_upload = list(name = cache$name, datapath = cache$datapath),
          header      = cache$header,
          separator   = cache$separator,
          quote       = cache$quote,
          row_names   = row_names
        )
      }
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

bgc_dr_cache_env <- new.env(parent = emptyenv())

bgc_dr_cache_clear <- function() {
  rm(list = ls(bgc_dr_cache_env, all.names = TRUE), envir = bgc_dr_cache_env)
  invisible(NULL)
}

bgc_dr_cache_size <- function() {
  length(ls(bgc_dr_cache_env, all.names = TRUE))
}

bgc_cached_compute <- function(key, compute) {
  stopifnot(is.function(compute))
  hash <- digest::digest(key, algo = "xxhash64")
  if (exists(hash, envir = bgc_dr_cache_env, inherits = FALSE)) {
    return(get(hash, envir = bgc_dr_cache_env))
  }
  result <- compute()
  assign(hash, result, envir = bgc_dr_cache_env)
  result
}

bgc_to_r_literal <- function(v) {
  if (is.character(v)) {
    if (length(v) == 1L) return(deparse(v))
    return(paste0("c(", paste(vapply(v, deparse, character(1)), collapse = ", "), ")"))
  }
  if (is.logical(v) || is.numeric(v)) {
    if (length(v) == 1L) return(as.character(v))
    return(paste0("c(", paste(as.character(v), collapse = ", "), ")"))
  }
  deparse(v)
}

# --- ggplot2 object -> R code (best-effort deparse) ---------------------------
# Walks a ggplot object (the one each module stashes as `vals$p`) and emits an
# approximately-executable R script. The goal is to show the user the
# structure of the plot they just built -- perfect round-tripping of every
# theme tweak is explicitly a non-goal.

`%bgc_or%` <- function(a, b) if (is.null(a)) b else a

bgc_deparse_expr <- function(x) {
  if (is.null(x)) return("")
  txt <- tryCatch(
    paste(deparse(x, width.cutoff = 500L), collapse = " "),
    error = function(e) "<unreadable>"
  )
  trimws(gsub("\\s+", " ", txt))
}

bgc_deparse_mapping <- function(mapping) {
  if (is.null(mapping)) return("")
  parts <- character()
  for (nm in names(mapping)) {
    val <- mapping[[nm]]
    if (is.null(val)) next
    expr <- if (rlang::is_quosure(val)) {
      rlang::quo_get_expr(val)
    } else if (inherits(val, "formula") && length(val) >= 2L) {
      val[[length(val)]]
    } else {
      val
    }
    txt <- bgc_deparse_expr(expr)
    if (!nzchar(txt)) next
    parts <- c(parts, sprintf("%s = %s", nm, txt))
  }
  if (length(parts) == 0L) return("")
  paste0("aes(", paste(parts, collapse = ", "), ")")
}

bgc_class_to_snake <- function(cls) {
  out <- gsub("([A-Z])", "_\\1", cls)
  sub("^_", "", tolower(out))
}

bgc_layer_fun_name <- function(layer) {
  geom_cls <- class(layer$geom)[1]
  stat_cls <- class(layer$stat)[1]
  geom_name <- bgc_class_to_snake(geom_cls)
  stat <- NULL
  if (!is.null(stat_cls) && !identical(stat_cls, "StatIdentity")) {
    stat <- sub("^stat_", "", bgc_class_to_snake(stat_cls))
  }
  list(fun = geom_name, stat = stat)
}

bgc_format_layer_arg <- function(nm, v) {
  if (is.null(v)) return(NULL)
  if (is.function(v)) return(NULL)
  if (inherits(v, "ggproto")) return(NULL)
  if (inherits(v, "Scale")) return(NULL)
  if (is.list(v) && !is.data.frame(v)) return(NULL)
  if (is.atomic(v) && length(v) == 0L) return(NULL)
  sprintf("%s = %s", nm, bgc_to_r_literal(v))
}

bgc_strip_defaults <- function(fun_name, params) {
  if (length(params) == 0L) return(params)
  ns <- tryCatch(asNamespace("ggplot2"), error = function(e) NULL)
  if (is.null(ns) || !exists(fun_name, envir = ns, inherits = FALSE)) return(params)
  f <- get(fun_name, envir = ns)
  default_args <- tryCatch(formals(f), error = function(e) NULL)
  if (is.null(default_args)) return(params)

  kept <- list()
  for (nm in names(params)) {
    if (!nm %in% names(default_args)) {
      kept[[nm]] <- params[[nm]]
      next
    }
    default_val <- tryCatch(
      eval(default_args[[nm]], envir = ns),
      error = function(e) NULL
    )
    if (!is.null(default_val) && identical(default_val, params[[nm]])) next
    if (is.symbol(default_args[[nm]]) && identical(as.character(default_args[[nm]]), "")) next
    kept[[nm]] <- params[[nm]]
  }
  kept
}

bgc_deparse_layer <- function(layer) {
  info <- bgc_layer_fun_name(layer)
  args <- character()

  if (!is.null(layer$mapping) && length(layer$mapping) > 0L) {
    m <- bgc_deparse_mapping(layer$mapping)
    if (nzchar(m)) args <- c(args, paste0("mapping = ", m))
  }

  if (!is.null(info$stat)) {
    args <- c(args, sprintf("stat = \"%s\"", info$stat))
  }

  pos <- layer$position
  if (!is.null(pos)) {
    pos_cls <- class(pos)[1]
    if (!identical(pos_cls, "PositionIdentity")) {
      pos_name <- sub("^position_", "", bgc_class_to_snake(pos_cls))
      args <- c(args, sprintf("position = \"%s\"", pos_name))
    }
  }

  aes_params <- layer$aes_params %bgc_or% list()
  geom_params <- layer$geom_params %bgc_or% list()

  merged <- c(aes_params, geom_params[setdiff(names(geom_params), names(aes_params))])
  merged <- bgc_strip_defaults(info$fun, merged)

  for (nm in names(merged)) {
    a <- bgc_format_layer_arg(nm, merged[[nm]])
    if (!is.null(a)) args <- c(args, a)
  }

  sprintf("%s(%s)", info$fun, paste(args, collapse = ", "))
}

bgc_deparse_scale <- function(sc) {
  aes <- (sc$aesthetics %bgc_or% "unknown")[1]
  name <- sc$scale_name %bgc_or% bgc_class_to_snake(class(sc)[1])
  if (aes %in% c("x", "y") && identical(name, "position_c")) return("")
  sprintf("scale_%s_%s()", aes, name)
}

bgc_deparse_facet <- function(facet) {
  if (is.null(facet)) return("")
  cls <- class(facet)[1]
  if (identical(cls, "FacetNull")) return("")
  params <- facet$params %bgc_or% list()
  quo_to_txt <- function(q) bgc_deparse_expr(rlang::quo_get_expr(q))

  if (identical(cls, "FacetWrap")) {
    facets <- params$facets %bgc_or% list()
    vars <- vapply(facets, quo_to_txt, character(1))
    if (length(vars) == 0L) return("facet_wrap()")
    return(sprintf("facet_wrap(vars(%s))", paste(vars, collapse = ", ")))
  }

  if (identical(cls, "FacetGrid")) {
    row_vars <- vapply(params$rows %bgc_or% list(), quo_to_txt, character(1))
    col_vars <- vapply(params$cols %bgc_or% list(), quo_to_txt, character(1))
    rows_txt <- if (length(row_vars) > 0L) {
      sprintf("rows = vars(%s)", paste(row_vars, collapse = ", "))
    } else "rows = NULL"
    cols_txt <- if (length(col_vars) > 0L) {
      sprintf("cols = vars(%s)", paste(col_vars, collapse = ", "))
    } else "cols = NULL"
    return(sprintf("facet_grid(%s, %s)", rows_txt, cols_txt))
  }

  sprintf("%s()", bgc_class_to_snake(cls))
}

bgc_deparse_coord <- function(coord) {
  if (is.null(coord)) return("")
  cls <- class(coord)[1]
  if (identical(cls, "CoordCartesian")) return("")
  sprintf("%s()", bgc_class_to_snake(cls))
}

bgc_deparse_labels <- function(lbls) {
  if (is.null(lbls) || length(lbls) == 0L) return("")
  keep <- list()
  for (nm in names(lbls)) {
    v <- lbls[[nm]]
    if (is.null(v)) next
    if (is.character(v) && !nzchar(v)) next
    keep[[nm]] <- v
  }
  if (length(keep) == 0L) return("")
  parts <- vapply(names(keep), function(nm) {
    val <- keep[[nm]]
    txt <- if (is.character(val)) deparse(val) else bgc_deparse_expr(val)
    sprintf("%s = %s", nm, txt)
  }, character(1))
  sprintf("labs(%s)", paste(parts, collapse = ", "))
}

bgc_deparse_theme <- function(theme_obj) {
  if (is.null(theme_obj) || length(theme_obj) == 0L) return("")
  "theme()  # CloudChart theme / text sizing applied -- see parameter snapshot"
}

bgc_ggplot_to_code <- function(p, data_name = "df") {
  if (!inherits(p, "ggplot")) {
    return("# Click the Plot button to generate visualization code.")
  }

  header <- c(
    "library(ggplot2)",
    "library(dplyr)",
    "",
    sprintf("# Replace %s with your data.frame, e.g.", data_name),
    sprintf("# %s <- read.csv(\"your_file.csv\", check.names = FALSE)", data_name),
    ""
  )

  pieces <- character()

  base_mapping <- tryCatch(
    bgc_deparse_mapping(p$mapping),
    error = function(e) ""
  )
  pieces <- c(pieces, if (nzchar(base_mapping)) {
    sprintf("ggplot(%s, %s)", data_name, base_mapping)
  } else {
    sprintf("ggplot(%s)", data_name)
  })

  for (layer in (p$layers %bgc_or% list())) {
    pieces <- c(pieces, tryCatch(
      bgc_deparse_layer(layer),
      error = function(e) "# <layer deparse failed>"
    ))
  }

  for (sc in (p$scales$scales %bgc_or% list())) {
    code <- tryCatch(bgc_deparse_scale(sc), error = function(e) "")
    if (nzchar(code)) pieces <- c(pieces, code)
  }

  for (tag in c("facet", "coord", "labs", "theme")) {
    code <- tryCatch(
      switch(tag,
        facet = bgc_deparse_facet(p$facet),
        coord = bgc_deparse_coord(p$coordinates),
        labs  = bgc_deparse_labels(p$labels),
        theme = bgc_deparse_theme(p$theme)
      ),
      error = function(e) ""
    )
    if (nzchar(code)) pieces <- c(pieces, code)
  }

  body_lines <- character(length(pieces))
  body_lines[1] <- paste0("p <- ", pieces[1])
  if (length(pieces) > 1L) {
    body_lines[1] <- paste0(body_lines[1], " +")
    for (i in 2:length(pieces)) {
      suffix <- if (i < length(pieces)) " +" else ""
      body_lines[i] <- paste0("  ", pieces[i], suffix)
    }
  }

  c(header, body_lines, "", "print(p)")
}

bgc_reproduce_script <- function(filename_prefix, input) {
  snapshot <- bgc_serialize_inputs(input)

  param_body <- if (length(snapshot) == 0L) {
    "  # (no parameters captured)"
  } else {
    nms <- names(snapshot)
    entries <- vapply(seq_along(snapshot), function(i) {
      sprintf("  %s = %s", nms[i], bgc_to_r_literal(snapshot[[i]]))
    }, character(1))
    paste(entries, collapse = ",\n")
  }

  c(
    sprintf("# CloudChart reproduce script -- %s", filename_prefix),
    sprintf("# generated %s", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
    "#",
    "# This script captures the parameters you used in CloudChart so you can",
    "# continue the analysis in your own R session. Replace the data-loading",
    "# stub with your real file and adapt the plotting block as needed.",
    "",
    "library(ggplot2)",
    "library(dplyr)",
    "",
    "# 1. Load your data ----------------------------------------------------",
    "# df <- read.csv(\"path/to/your_file.csv\", check.names = FALSE)",
    "df <- NULL  # <-- replace with your data.frame",
    "",
    "# 2. CloudChart parameters ---------------------------------------------",
    "params <- list(",
    param_body,
    ")",
    "",
    "# 3. Reproduce the plot ------------------------------------------------",
    "# Paste the ggplot2 recipe that matches your CloudChart module here,",
    "# using `df` and `params`. Minimal skeleton:",
    "#",
    "# p <- ggplot(df, aes(x = .data[[params$x_axis]], y = .data[[params$y_axis]])) +",
    "#   geom_point()",
    "# print(p)",
    ""
  )
}

bind_plot_outputs <- function(output, input, plot_reactive, vals, filename_prefix, data_fn = NULL) {
  output$plotOutput <- renderPlot({
    plot_reactive()
  })

  output$plotCode <- renderText({
    p <- vals$p
    if (is.null(p)) {
      return("# Click the Plot button to generate visualization code.")
    }
    code <- tryCatch(
      bgc_ggplot_to_code(p),
      error = function(e) paste("# Code extraction failed:", conditionMessage(e))
    )
    paste(code, collapse = "\n")
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

  output$DownloadScript <- downloadHandler(
    filename = function() {
      paste0(filename_prefix, "_reproduce_", Sys.Date(), ".R")
    },
    content = function(file) {
      writeLines(bgc_reproduce_script(filename_prefix, input), file)
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
