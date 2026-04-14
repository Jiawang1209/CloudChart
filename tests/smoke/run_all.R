#!/usr/bin/env Rscript
# Run all CloudChart smoke tests from the project root:
#   Rscript tests/smoke/run_all.R
#
# Each test script is launched in its own Rscript subprocess so that a
# failing script's quit(status=1) doesn't kill the runner, and so that each
# script gets a clean R session (important for the lazy-boot test which
# asserts on pristine bgc_loaded_groups state).

if (!file.exists("R/core/app_bootstrap.R")) {
  stop("run_all.R must be invoked from the CloudChart project root")
}

scripts <- c(
  "tests/smoke/test_module_registry.R",
  "tests/smoke/test_example_roundtrip.R",
  "tests/smoke/test_lazy_boot.R",
  "tests/smoke/test_dt_click.R"
)

rscript <- file.path(R.home("bin"), "Rscript")
failures <- character(0)

for (s in scripts) {
  cat("\n########  ", s, "  ########\n", sep = "")
  status <- system2(rscript, args = s, stdout = "", stderr = "")
  if (status != 0L) failures <- c(failures, s)
}

cat("\n========================================\n")
if (length(failures) > 0L) {
  cat("FAILED scripts:\n")
  for (f in failures) cat("  - ", f, "\n", sep = "")
  quit(status = 1L, save = "no")
}
cat("ALL SMOKE TESTS PASSED\n")
