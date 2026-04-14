source("tests/smoke/_helpers.R")
bgc_smoke_bootstrap()

bgc_smoke_section("module registry")

expected_groups <- c("core", "advanced", "statistics", "data_tools")
bgc_smoke_assert(
  identical(sort(names(bgc_plot_specs)), sort(expected_groups)),
  "bgc_plot_specs covers all 4 groups"
)
bgc_smoke_assert(
  identical(sort(names(bgc_module_files)), sort(expected_groups)),
  "bgc_module_files covers all 4 groups"
)
bgc_smoke_assert(
  identical(sort(names(bgc_group_menu_config)), sort(expected_groups)),
  "bgc_group_menu_config covers all 4 groups"
)

for (g in expected_groups) {
  files <- bgc_module_files[[g]]
  missing <- files[!file.exists(files)]
  bgc_smoke_assert(
    length(missing) == 0L,
    sprintf("all bgc_module_files paths exist for group '%s' (missing: %s)",
            g, paste(missing, collapse = ", "))
  )
}

for (spec in bgc_smoke_all_specs()) {
  label <- sprintf("[%s/%s]", spec$.group, spec$id)

  bgc_smoke_assert(
    is.character(spec$id) && nzchar(spec$id),
    sprintf("%s has non-empty id", label)
  )
  bgc_smoke_assert(
    is.character(spec$title) && nzchar(spec$title),
    sprintf("%s has non-empty title", label)
  )

  bgc_smoke_assert(
    is.character(spec$parameter_ui) &&
      exists(spec$parameter_ui, mode = "function"),
    sprintf("%s parameter_ui '%s' is a loaded function", label, spec$parameter_ui %||% "NULL")
  )
  bgc_smoke_assert(
    is.character(spec$server_fun) &&
      exists(spec$server_fun, mode = "function"),
    sprintf("%s server_fun '%s' is a loaded function", label, spec$server_fun %||% "NULL")
  )

  if (!is.null(spec$example_data) && nzchar(spec$example_data)) {
    bgc_smoke_assert(
      exists(spec$example_data, envir = .GlobalEnv, inherits = TRUE) &&
        is.data.frame(get(spec$example_data)),
      sprintf("%s example_data '%s' resolves to a data.frame",
              label, spec$example_data)
    )
  }

  layout <- if (is.null(spec$layout)) "plot" else spec$layout
  bgc_smoke_assert(
    layout %in% c("plot", "stats", "data_tools"),
    sprintf("%s layout '%s' is a known layout key", label, layout)
  )
}

bgc_smoke_report()
