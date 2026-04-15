source("tests/smoke/_helpers.R")
bgc_smoke_bootstrap()

suppressPackageStartupMessages(library(shiny))

bgc_smoke_section("server factory promise binding (regression: 2026-04-15 ggplot)")

captured <- new.env(parent = emptyenv())
captured$rows <- list()

orig_register <- bgc_register_plot_servers
bgc_register_plot_servers <- function(specs, group, active_tab, output) {
  force(specs); force(group)
  for (spec in specs) local({
    spec <- spec
    group <- group
    captured$rows[[length(captured$rows) + 1L]] <<-
      list(spec_id = spec$id, group = group)
  })
}
on.exit(assign("bgc_register_plot_servers", orig_register, envir = .GlobalEnv),
        add = TRUE)

server_factory <- bgc_plot_app_server(
  groups = c("core", "advanced", "statistics", "data_tools"),
  include_home = TRUE
)

testServer(server_factory, {
  session$flushReact()
})

bgc_register_plot_servers <- orig_register

expected_lookup <- character()
for (g in names(bgc_plot_specs)) {
  for (s in bgc_plot_specs[[g]]) expected_lookup[[s$id]] <- g
}

bgc_smoke_assert(
  length(captured$rows) == sum(lengths(bgc_plot_specs)),
  sprintf("server factory registered one closure per spec (got %d, expect %d)",
          length(captured$rows), sum(lengths(bgc_plot_specs)))
)

mismatches <- 0L
for (r in captured$rows) {
  want <- expected_lookup[[r$spec_id]]
  if (!identical(r$group, want)) {
    mismatches <- mismatches + 1L
    cat("  MISMATCH spec=", r$spec_id, " captured=", r$group,
        " expected=", want, "\n", sep = "")
  }
}
bgc_smoke_assert(
  mismatches == 0L,
  sprintf("every observer captured its own group (mismatches=%d)", mismatches)
)

bgc_smoke_section("UI factory builds for hub + each sub app")

hub_ui <- tryCatch(
  bgc_plot_app_ui(
    app_title = "CloudChart",
    groups = c("core", "advanced", "statistics", "data_tools"),
    include_home = TRUE,
    include_intro = TRUE
  ),
  error = function(e) e
)
bgc_smoke_assert(
  !inherits(hub_ui, "error"),
  if (inherits(hub_ui, "error"))
    paste0("hub UI build failed: ", conditionMessage(hub_ui))
  else
    "hub UI builds without error"
)

for (g in names(bgc_plot_specs)) {
  ui <- tryCatch(
    bgc_plot_app_ui(
      app_title = paste0("CloudChart - ", g),
      groups = g,
      include_home = FALSE,
      include_intro = TRUE
    ),
    error = function(e) e
  )
  bgc_smoke_assert(
    !inherits(ui, "error"),
    if (inherits(ui, "error"))
      sprintf("sub app '%s' UI build failed: %s", g, conditionMessage(ui))
    else
      sprintf("sub app '%s' UI builds without error", g)
  )
}

bgc_smoke_section("server factory builds for each entrypoint")

server_specs <- list(
  list(name = "hub",            groups = c("core", "advanced", "statistics", "data_tools"), home = TRUE),
  list(name = "core_plots",     groups = "core",       home = FALSE),
  list(name = "advanced_plots", groups = "advanced",   home = FALSE),
  list(name = "statistics",     groups = "statistics", home = FALSE),
  list(name = "data_tools",     groups = "data_tools", home = FALSE)
)
for (cfg in server_specs) {
  fn <- tryCatch(
    bgc_plot_app_server(cfg$groups, include_home = cfg$home),
    error = function(e) e
  )
  bgc_smoke_assert(
    !inherits(fn, "error") && is.function(fn),
    if (inherits(fn, "error"))
      sprintf("server factory '%s' failed: %s", cfg$name, conditionMessage(fn))
    else
      sprintf("server factory '%s' builds", cfg$name)
  )
}

bgc_smoke_section("ggplot-using modules belong to groups that declare ggplot2")

for (g in names(bgc_module_files)) {
  group_pkgs <- bgc_group_packages[[g]]
  for (f in bgc_module_files[[g]]) {
    if (grepl("_parameters\\.R$", f)) next
    code <- readLines(f, warn = FALSE)
    uses_ggplot <- any(grepl("\\bggplot\\(", code))
    if (uses_ggplot) {
      bgc_smoke_assert(
        "ggplot2" %in% group_pkgs,
        sprintf("module %s uses ggplot() and group '%s' declares ggplot2",
                basename(f), g)
      )
    }
  }
}

bgc_smoke_report()
