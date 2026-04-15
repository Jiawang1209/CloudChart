# app_bootstrap.R
#
# Two-tier loader for the CloudChart hub + sub apps.
#
# Tier 1 (base): always loaded. Lightweight Shiny shell, factory, specs.
#                Lets the portal hub start with no plotting deps.
# Tier 2 (plot): only loaded when at least one plotting group is requested.
#                Pulls in ggplot2 helpers, file upload, plot download, etc.
#
# Per-group packages and module files are declared in R/app_specs.R via
# `bgc_group_packages` and `bgc_module_files`.

bgc_init_runtime <- function(root_dir) {
  Sys.setenv(LANGUAGE = "en")
  options(shiny.maxRequestSize = 1000 * 1024^2)
  options(bgc.root_dir = normalizePath(root_dir, mustWork = TRUE))
  if (requireNamespace("showtext", quietly = TRUE)) {
    showtext::showtext_auto()
  }
}

bgc_root_dir <- function() {
  normalizePath(getOption("bgc.root_dir", getwd()), mustWork = TRUE)
}

bgc_project_path <- function(...) {
  file.path(bgc_root_dir(), ...)
}

bgc_register_resources <- function(root_dir) {
  shiny::addResourcePath("bgc-www", file.path(root_dir, "www"))
}

bgc_attach_packages <- function(groups = character()) {
  base_pkgs <- bgc_group_packages$base
  group_pkgs <- unique(unlist(bgc_group_packages[groups], use.names = FALSE))
  pkgs <- unique(c(base_pkgs, group_pkgs))
  for (p in pkgs) {
    suppressPackageStartupMessages(
      library(p, character.only = TRUE)
    )
  }
}

# Per-process tracker of which groups have already had their runtime packages attached.
bgc_loaded_groups <- new.env(parent = emptyenv())
bgc_load_history <- new.env(parent = emptyenv())

bgc_ensure_group_loaded <- function(group) {
  if (!nzchar(group)) return(invisible(FALSE))
  if (isTRUE(bgc_loaded_groups[[group]])) return(invisible(FALSE))
  pkgs <- bgc_group_packages[[group]]
  t0 <- Sys.time()
  if (length(pkgs) > 0) {
    for (p in pkgs) {
      suppressPackageStartupMessages(
        library(p, character.only = TRUE)
      )
    }
  }
  bgc_loaded_groups[[group]] <- TRUE
  bgc_load_history[[group]] <- list(
    loaded_at = t0,
    elapsed_s = as.numeric(difftime(Sys.time(), t0, units = "secs")),
    n_pkgs    = length(pkgs)
  )
  bgc_log("group loaded: ", group, " (", length(pkgs), " pkgs)", level = "debug")
  invisible(TRUE)
}

# ---- Logging ----------------------------------------------------------------
# Single entry point for diagnostic output. Levels:
#   debug / info  — gated on getOption("bgc.debug", FALSE); silent by default.
#   warn / error  — always emitted (via warning() / message()).
# Usage:
#   bgc_log("loader: attaching ", pkg)                       # debug
#   bgc_log("spec ", id, " missing", level = "warn")
# Enable verbose tracing with: options(bgc.debug = TRUE)
bgc_log <- function(..., level = c("debug", "info", "warn", "error")) {
  level <- match.arg(level)
  gated <- level %in% c("debug", "info")
  if (gated && !isTRUE(getOption("bgc.debug", FALSE))) return(invisible(NULL))
  msg <- paste0("[bgc ", level, "] ", paste0(..., collapse = ""))
  message(msg)
  invisible(NULL)
}

# Dump current lazy-loader state for debugging timing / ordering issues.
# Returns a data.frame (one row per requested group) and prints a short
# summary when `print = TRUE`.
bgc_debug_report <- function(print = TRUE) {
  groups <- union(
    names(as.list(bgc_loaded_groups)),
    names(as.list(bgc_load_history))
  )
  if (length(groups) == 0L) {
    df <- data.frame(
      group = character(0), loaded = logical(0),
      loaded_at = as.POSIXct(character(0)),
      elapsed_s = numeric(0), n_pkgs = integer(0),
      stringsAsFactors = FALSE
    )
  } else {
    df <- do.call(rbind, lapply(groups, function(g) {
      h <- bgc_load_history[[g]]
      data.frame(
        group     = g,
        loaded    = isTRUE(bgc_loaded_groups[[g]]),
        loaded_at = if (is.null(h)) as.POSIXct(NA) else h$loaded_at,
        elapsed_s = if (is.null(h)) NA_real_ else h$elapsed_s,
        n_pkgs    = if (is.null(h)) NA_integer_ else as.integer(h$n_pkgs),
        stringsAsFactors = FALSE
      )
    }))
    df <- df[order(df$loaded_at, df$group), , drop = FALSE]
    rownames(df) <- NULL
  }
  if (isTRUE(print)) {
    cat("[bgc] lazy-loader state (", nrow(df), " groups)\n", sep = "")
    if (nrow(df) > 0L) print(df, row.names = FALSE)
  }
  invisible(df)
}

bgc_source_files <- function(root_dir, files) {
  for (file in files) {
    source(file.path(root_dir, file), local = globalenv())
  }
}

# Files needed by ANY entrypoint (including the portal hub).
bgc_base_shared_files <- c(
  "R/core/homepage.R",
  "R/core/Introduction_UI.R",
  "R/core/module_myCarousel_UI_Server.R",
  "R/core/component4UI.R",
  "R/core/app_specs.R",
  "R/core/app_factory.R"
)

# Files needed only by sub apps that actually render plots.
bgc_plot_shared_files <- c(
  "R/shared/module_ggplot2_plot_download.R",
  "R/shared/module_ggplot2_plotly.R",
  "R/shared/module_show_example_data.R",
  "R/shared/module_file_upload.R",
  "R/shared/module_plot_helpers.R",
  "R/shared/basic_advance_plot_UI.R",
  "R/shared/basic_stats_UI.R",
  "R/shared/basic_data_tools_UI.R"
)

bgc_load_example_data <- function(root_dir) {
  path <- file.path(root_dir, "test_data.Rdata")
  if (file.exists(path)) {
    load(path, envir = globalenv())
  }
}

bgc_bootstrap <- function(root_dir, groups = character()) {
  bgc_init_runtime(root_dir)
  bgc_register_resources(root_dir)

  # Specs must be sourced before package attach so bgc_group_packages is visible.
  bgc_source_files(root_dir, bgc_base_shared_files)

  # Only base packages get attached eagerly. Group-specific runtime packages
  # are deferred until the user navigates into that group's tab.
  bgc_attach_packages(character())

  if (length(groups) > 0) {
    plotting_groups <- intersect(groups, names(bgc_module_files))
    has_plot_modules <- any(
      vapply(
        plotting_groups,
        function(g) length(bgc_module_files[[g]]) > 0,
        logical(1)
      )
    )

    if (has_plot_modules) {
      # Sourcing module files only defines functions — package-dependent code
      # lives inside reactive bodies, so this stays cheap.
      bgc_source_files(root_dir, bgc_plot_shared_files)
      module_files <- unique(unlist(bgc_module_files[plotting_groups], use.names = FALSE))
      bgc_source_files(root_dir, module_files)
      bgc_load_example_data(root_dir)
    }
  }
}
