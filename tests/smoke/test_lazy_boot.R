source("tests/smoke/_helpers.R")
bgc_smoke_bootstrap()

bgc_smoke_section("lazy boot state")

bgc_smoke_assert(
  exists("bgc_loaded_groups", envir = .GlobalEnv, inherits = TRUE),
  "bgc_loaded_groups registry exists after bootstrap"
)

pre_boot_empty <- length(as.list(bgc_loaded_groups)) == 0L ||
  all(vapply(as.list(bgc_loaded_groups), function(v) isFALSE(v), logical(1)))
bgc_smoke_assert(
  pre_boot_empty,
  sprintf("no group packages attached at boot (state: %s)",
          paste(names(as.list(bgc_loaded_groups)),
                as.list(bgc_loaded_groups),
                sep = "=", collapse = ","))
)

bgc_smoke_assert(
  exists("bgc_body_fn_for", mode = "function"),
  "bgc_body_fn_for dispatcher is loaded"
)
bgc_smoke_assert(
  exists("bgc_register_plot_servers", mode = "function"),
  "bgc_register_plot_servers is loaded"
)

bgc_smoke_section("lazy body construction per layout")

probe_specs <- list(
  plot       = bgc_plot_specs$core[[1]],
  plot_adv   = bgc_plot_specs$advanced[[1]],
  stats      = bgc_plot_specs$statistics[[1]],
  data_tools = bgc_plot_specs$data_tools[[1]]
)
expected_tabs <- list(
  plot = 4, plot_adv = 4, stats = 3, data_tools = 3
)

for (probe in names(probe_specs)) {
  spec <- probe_specs[[probe]]
  bgc_ensure_group_loaded(spec$.group %||% switch(
    probe, plot = "core", plot_adv = "advanced",
    stats = "statistics", data_tools = "data_tools"
  ))

  body_fn <- bgc_body_fn_for(spec)
  ui <- tryCatch(body_fn(spec$id, spec$parameter_ui),
                 error = function(e) { cat("    body_fn error: ", conditionMessage(e), "\n", sep = ""); NULL })

  bgc_smoke_assert(
    !is.null(ui),
    sprintf("[%s/%s] body_fn returns a UI object", probe, spec$id)
  )
  if (is.null(ui)) next

  html <- as.character(ui)
  tab_hits <- length(gregexpr("nav-item", html, fixed = TRUE)[[1]])
  bgc_smoke_assert(
    tab_hits == expected_tabs[[probe]],
    sprintf("[%s/%s] bs4TabCard has %d nav-items (got %d)",
            probe, spec$id, expected_tabs[[probe]], tab_hits)
  )
  bgc_smoke_assert(
    grepl("nav-pills", html, fixed = TRUE) &&
      grepl("card-tabs", html, fixed = TRUE),
    sprintf("[%s/%s] bs4TabCard nav-pills/card-tabs classes present", probe, spec$id)
  )
}

all_groups <- c("core", "advanced", "statistics", "data_tools")
post <- vapply(all_groups, function(g) isTRUE(bgc_loaded_groups[[g]]), logical(1))
bgc_smoke_assert(
  all(post),
  sprintf("all 4 groups flipped to loaded after probing (%s)",
          paste(all_groups, post, sep = "=", collapse = ","))
)

bgc_smoke_report()
