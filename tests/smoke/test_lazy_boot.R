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
  plot = 5, plot_adv = 5, stats = 3, data_tools = 3
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

bgc_smoke_section("bgc_log gating")

bgc_smoke_assert(
  exists("bgc_log", mode = "function"),
  "bgc_log helper is loaded"
)

# debug is silent when bgc.debug is FALSE / unset
options(bgc.debug = FALSE)
silent_msgs <- capture.output(
  bgc_log("should-not-appear", level = "debug"),
  type = "message"
)
bgc_smoke_assert(
  length(silent_msgs) == 0L,
  sprintf("debug level is silent when bgc.debug=FALSE (got %d lines)",
          length(silent_msgs))
)

# debug emits when the option is on
options(bgc.debug = TRUE)
debug_msgs <- capture.output(
  bgc_log("hello-debug", level = "debug"),
  type = "message"
)
bgc_smoke_assert(
  any(grepl("hello-debug", debug_msgs, fixed = TRUE)),
  "debug level emits when bgc.debug=TRUE"
)
options(bgc.debug = FALSE)

# warn always emits, even when gated off
warn_msgs <- capture.output(
  bgc_log("boom", level = "warn"),
  type = "message"
)
bgc_smoke_assert(
  any(grepl("boom", warn_msgs, fixed = TRUE)),
  "warn level emits regardless of bgc.debug flag"
)

bgc_smoke_section("bgc_debug_report")

bgc_smoke_assert(
  exists("bgc_debug_report", mode = "function"),
  "bgc_debug_report helper is loaded"
)

report <- suppressWarnings(
  utils::capture.output(bgc_debug_report(print = TRUE))
)
df <- bgc_debug_report(print = FALSE)
bgc_smoke_assert(
  is.data.frame(df) && all(c("group", "loaded", "loaded_at", "elapsed_s", "n_pkgs") %in% names(df)),
  "bgc_debug_report returns a data.frame with expected columns"
)
bgc_smoke_assert(
  nrow(df) >= length(all_groups) &&
    all(all_groups %in% df$group) &&
    all(df$loaded[df$group %in% all_groups]),
  "bgc_debug_report lists all probed groups as loaded"
)
bgc_smoke_assert(
  any(grepl("lazy-loader state", report, fixed = TRUE)),
  "bgc_debug_report prints a header when print=TRUE"
)

bgc_smoke_report()
