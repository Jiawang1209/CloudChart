bgc_smoke_state <- new.env(parent = emptyenv())
bgc_smoke_state$passed <- 0L
bgc_smoke_state$failed <- 0L
bgc_smoke_state$failures <- character(0)

bgc_smoke_assert <- function(cond, message) {
  if (isTRUE(cond)) {
    bgc_smoke_state$passed <- bgc_smoke_state$passed + 1L
  } else {
    bgc_smoke_state$failed <- bgc_smoke_state$failed + 1L
    bgc_smoke_state$failures <- c(bgc_smoke_state$failures, message)
    cat("  FAIL ", message, "\n", sep = "")
  }
}

bgc_smoke_section <- function(label) {
  cat("\n==[ ", label, " ]==\n", sep = "")
}

bgc_smoke_report <- function() {
  cat("\n----\n")
  cat("passed: ", bgc_smoke_state$passed,
      "  failed: ", bgc_smoke_state$failed, "\n", sep = "")
  if (bgc_smoke_state$failed > 0L) {
    cat("\nFailures:\n")
    for (msg in bgc_smoke_state$failures) cat(" - ", msg, "\n", sep = "")
    quit(status = 1L, save = "no")
  }
  invisible(TRUE)
}

bgc_smoke_bootstrap <- function() {
  suppressPackageStartupMessages({
    source("R/core/app_bootstrap.R")
    bgc_bootstrap(getwd(), groups = c("core", "advanced", "statistics", "data_tools"))
  })
}

bgc_smoke_all_specs <- function() {
  specs <- list()
  for (g in names(bgc_plot_specs)) {
    for (spec in bgc_plot_specs[[g]]) {
      spec$.group <- g
      specs[[length(specs) + 1L]] <- spec
    }
  }
  specs
}
