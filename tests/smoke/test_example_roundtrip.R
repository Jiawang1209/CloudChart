source("tests/smoke/_helpers.R")
bgc_smoke_bootstrap()

bgc_smoke_section("example data round-trip")

simulate_download <- function(df, path) {
  utils::write.csv(df, file = path, row.names = FALSE, fileEncoding = "UTF-8")
}

simulate_upload <- function(path, original_name) {
  fake_file <- list(name = original_name, datapath = path)
  read_uploaded_table(
    file_upload = fake_file,
    header      = TRUE,
    separator   = "auto",
    quote       = "\"",
    row_names   = FALSE
  )
}

seen_examples <- character(0)

for (spec in bgc_smoke_all_specs()) {
  if (is.null(spec$example_data) || !nzchar(spec$example_data)) next
  if (spec$example_data %in% seen_examples) next
  seen_examples <- c(seen_examples, spec$example_data)

  label <- sprintf("[%s] %s", spec$example_data, spec$id)

  original <- tryCatch(get(spec$example_data, envir = .GlobalEnv),
                       error = function(e) NULL)
  bgc_smoke_assert(
    is.data.frame(original),
    sprintf("%s example resolves to data.frame", label)
  )
  if (!is.data.frame(original)) next

  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE, after = FALSE)
  simulate_download(original, tmp)

  roundtrip <- tryCatch(
    simulate_upload(tmp, paste0(spec$example_data, ".csv")),
    error = function(e) { cat("    read_uploaded_table error: ", conditionMessage(e), "\n", sep = ""); NULL }
  )

  bgc_smoke_assert(
    is.data.frame(roundtrip),
    sprintf("%s upload returns a data.frame", label)
  )
  if (!is.data.frame(roundtrip)) next

  bgc_smoke_assert(
    ncol(roundtrip) == ncol(original),
    sprintf("%s column count preserved (expected %d, got %d)",
            label, ncol(original), ncol(roundtrip))
  )
  bgc_smoke_assert(
    nrow(roundtrip) == nrow(original),
    sprintf("%s row count preserved (expected %d, got %d)",
            label, nrow(original), nrow(roundtrip))
  )
  bgc_smoke_assert(
    identical(colnames(roundtrip), colnames(original)),
    sprintf("%s column names preserved (got: %s)",
            label, paste(colnames(roundtrip), collapse = ","))
  )

  blank_names <- colnames(roundtrip)[!nzchar(colnames(roundtrip))]
  bgc_smoke_assert(
    length(blank_names) == 0L,
    sprintf("%s has no blank column names (guards DT searchable[j] warning)",
            label)
  )
}

cat("round-tripped ", length(seen_examples), " distinct example datasets\n", sep = "")

bgc_smoke_section("sanitize_uploaded_table() edge cases")

dirty_fixture <- function() {
  df <- data.frame(
    a = 1:4,
    b = c(10, 20, 30, 40),
    c = c("x", "y", "z", "w"),
    d = c(NA, NA, NA, NA),
    e = 1:4,
    f = 5:8,
    stringsAsFactors = FALSE
  )
  names(df) <- c("id", "", "  label  ", "all_na", "dup", "dup")
  df
}

raw <- dirty_fixture()
cleaned <- sanitize_uploaded_table(raw)

bgc_smoke_assert(
  is.data.frame(cleaned),
  "sanitize returns a data.frame"
)
bgc_smoke_assert(
  all(nzchar(names(cleaned))),
  sprintf("sanitize removes blank column names (got: %s)",
          paste(names(cleaned), collapse = ","))
)
bgc_smoke_assert(
  anyDuplicated(names(cleaned)) == 0L,
  sprintf("sanitize deduplicates column names (got: %s)",
          paste(names(cleaned), collapse = ","))
)
bgc_smoke_assert(
  !("all_na" %in% names(cleaned)),
  "sanitize drops all-NA columns by default"
)
bgc_smoke_assert(
  ncol(cleaned) == 5L,
  sprintf("sanitize keeps 5 non-NA columns (got %d)", ncol(cleaned))
)
bgc_smoke_assert(
  "id" %in% names(cleaned),
  "sanitize preserves legal names verbatim"
)
bgc_smoke_assert(
  "label" %in% names(cleaned),
  sprintf("sanitize trims whitespace in names (got: %s)",
          paste(names(cleaned), collapse = ","))
)

dt_ok <- tryCatch(
  {
    DT::datatable(
      cleaned,
      rownames = FALSE,
      options = list(pageLength = 10)
    )
    TRUE
  },
  error = function(e) { cat("    DT error: ", conditionMessage(e), "\n", sep = ""); FALSE }
)
bgc_smoke_assert(
  isTRUE(dt_ok),
  "DT::datatable() constructs from sanitized frame without error"
)

kept_all_na <- sanitize_uploaded_table(
  data.frame(x = 1:3, y = c(NA, NA, NA)),
  drop_all_na_cols = FALSE
)
bgc_smoke_assert(
  "y" %in% names(kept_all_na),
  "sanitize keeps all-NA columns when drop_all_na_cols = FALSE"
)

bgc_smoke_section("read_uploaded_table() non-csv branches")

tsv_path <- tempfile(fileext = ".tsv")
on.exit(unlink(tsv_path), add = TRUE, after = FALSE)
utils::write.table(iris, file = tsv_path, sep = "\t", quote = FALSE,
                   row.names = FALSE, fileEncoding = "UTF-8")

tsv_rt <- tryCatch(
  read_uploaded_table(
    file_upload = list(name = "iris.tsv", datapath = tsv_path),
    header = TRUE, separator = "auto", quote = "\"", row_names = FALSE
  ),
  error = function(e) { cat("    tsv error: ", conditionMessage(e), "\n", sep = ""); NULL }
)
bgc_smoke_assert(
  is.data.frame(tsv_rt) && nrow(tsv_rt) == nrow(iris) && ncol(tsv_rt) == ncol(iris),
  "tsv round-trip preserves iris shape"
)
bgc_smoke_assert(
  is.data.frame(tsv_rt) && identical(colnames(tsv_rt), colnames(iris)),
  "tsv round-trip preserves iris column names"
)

has_writexl <- requireNamespace("writexl", quietly = TRUE)
if (has_writexl) {
  xlsx_path <- tempfile(fileext = ".xlsx")
  on.exit(unlink(xlsx_path), add = TRUE, after = FALSE)
  writexl::write_xlsx(iris, path = xlsx_path)

  xlsx_rt <- tryCatch(
    read_uploaded_table(
      file_upload = list(name = "iris.xlsx", datapath = xlsx_path),
      header = TRUE, separator = "auto", quote = "\"", row_names = FALSE
    ),
    error = function(e) { cat("    xlsx error: ", conditionMessage(e), "\n", sep = ""); NULL }
  )
  bgc_smoke_assert(
    is.data.frame(xlsx_rt) && nrow(xlsx_rt) == nrow(iris) && ncol(xlsx_rt) == ncol(iris),
    "xlsx round-trip preserves iris shape"
  )
  bgc_smoke_assert(
    is.data.frame(xlsx_rt) && identical(colnames(xlsx_rt), colnames(iris)),
    "xlsx round-trip preserves iris column names"
  )
} else {
  cat("  SKIP writexl not installed; xlsx round-trip not exercised\n")
}

bgc_smoke_section("plot export helpers (format dispatch)")

bgc_smoke_assert(
  identical(bgc_plot_extension("PDF"), "pdf") &&
    identical(bgc_plot_extension("pdf"), "pdf") &&
    identical(bgc_plot_extension("PNG"), "png") &&
    identical(bgc_plot_extension("svg"), "svg") &&
    identical(bgc_plot_extension(NULL), "pdf") &&
    identical(bgc_plot_extension(""), "pdf"),
  "bgc_plot_extension dispatches PDF/PNG/SVG and falls back to pdf"
)

fake_plot <- ggplot2::ggplot(iris, ggplot2::aes(Sepal.Length, Sepal.Width)) +
  ggplot2::geom_point()

pdf_out <- tempfile(fileext = ".pdf")
png_out <- tempfile(fileext = ".png")
svg_out <- tempfile(fileext = ".svg")
on.exit(unlink(c(pdf_out, png_out, svg_out)), add = TRUE, after = FALSE)

for (fmt in c("PDF", "PNG", "SVG")) {
  target <- switch(fmt, PDF = pdf_out, PNG = png_out, SVG = svg_out)
  ok <- tryCatch({
    bgc_plot_device(fmt, target, width = 4, height = 3)
    print(fake_plot)
    grDevices::dev.off()
    TRUE
  }, error = function(e) { grDevices::graphics.off(); FALSE })

  bgc_smoke_assert(
    isTRUE(ok) && file.exists(target) && file.info(target)$size > 0L,
    sprintf("bgc_plot_device writes non-empty %s file", fmt)
  )
}

bgc_smoke_section("bgc_serialize_inputs() filters shiny internals")

fake_input <- shiny::reactiveValues(
  Plot = 3,
  Download = 1,
  Format = "PNG",
  file_upload = list(name = "x.csv", datapath = "/tmp/x.csv"),
  file_output_rows_selected = c(1, 2, 3),
  submit_file = 0,
  x_axis = "Sepal.Length",
  y_axis = "Sepal.Width",
  label_size = 12,
  build_interactive_plot = 0,
  plot_title = "Demo",
  colour = c("red", "blue", "green")
)

snapshot <- shiny::isolate(bgc_serialize_inputs(fake_input))

bgc_smoke_assert(
  is.list(snapshot) && length(snapshot) > 0L,
  "bgc_serialize_inputs returns a non-empty list"
)
bgc_smoke_assert(
  identical(snapshot$x_axis, "Sepal.Length") &&
    identical(snapshot$y_axis, "Sepal.Width") &&
    identical(snapshot$label_size, 12) &&
    identical(snapshot$plot_title, "Demo"),
  "bgc_serialize_inputs keeps plain atomic plot parameters"
)
bgc_smoke_assert(
  is.null(snapshot$Plot) && is.null(snapshot$Download) && is.null(snapshot$Format) &&
    is.null(snapshot$submit_file) && is.null(snapshot$build_interactive_plot),
  "bgc_serialize_inputs drops action/download/format control inputs"
)
bgc_smoke_assert(
  is.null(snapshot$file_upload) && is.null(snapshot$file_output_rows_selected),
  "bgc_serialize_inputs drops file_upload and file_output_* internals"
)
bgc_smoke_assert(
  identical(snapshot$colour, c("red", "blue", "green")),
  "bgc_serialize_inputs keeps short atomic vectors"
)

yaml_blob <- yaml::as.yaml(snapshot)
yaml_rt <- yaml::yaml.load(yaml_blob)
bgc_smoke_assert(
  is.list(yaml_rt) && identical(yaml_rt$x_axis, "Sepal.Length"),
  "bgc_serialize_inputs output round-trips through yaml::as.yaml / yaml.load"
)

bgc_smoke_section("bgc_reproduce_script() emits valid R")

rv_repro <- shiny::reactiveValues(
  x_axis = "Sepal.Length",
  y_axis = "Sepal.Width",
  label_size = 12,
  plot_title = "Demo",
  colour = c("red", "blue")
)
script_lines <- shiny::isolate(bgc_reproduce_script("dot_plot", rv_repro))
script_text <- paste(script_lines, collapse = "\n")

bgc_smoke_assert(
  is.character(script_lines) && length(script_lines) > 10L,
  "bgc_reproduce_script returns a non-trivial character vector"
)
bgc_smoke_assert(
  grepl("CloudChart reproduce script -- dot_plot", script_text, fixed = TRUE),
  "reproduce script header names the module"
)
bgc_smoke_assert(
  grepl("library(ggplot2)", script_text, fixed = TRUE) &&
    grepl("library(dplyr)", script_text, fixed = TRUE),
  "reproduce script loads ggplot2 and dplyr"
)
bgc_smoke_assert(
  grepl("x_axis = \"Sepal.Length\"", script_text, fixed = TRUE) &&
    grepl("y_axis = \"Sepal.Width\"", script_text, fixed = TRUE) &&
    grepl("label_size = 12", script_text, fixed = TRUE) &&
    grepl("plot_title = \"Demo\"", script_text, fixed = TRUE),
  "reproduce script serializes scalar parameters as R literals"
)
bgc_smoke_assert(
  grepl("colour = c(\"red\", \"blue\")", script_text, fixed = TRUE),
  "reproduce script serializes short character vectors via c()"
)
bgc_smoke_assert(
  tryCatch({ parse(text = script_text); TRUE }, error = function(e) FALSE),
  "reproduce script parses as valid R"
)

rv_empty <- shiny::reactiveValues()
empty_script <- shiny::isolate(bgc_reproduce_script("empty_mod", rv_empty))
bgc_smoke_assert(
  any(grepl("(no parameters captured)", empty_script, fixed = TRUE)) &&
    tryCatch({ parse(text = paste(empty_script, collapse = "\n")); TRUE },
             error = function(e) FALSE),
  "reproduce script handles empty input gracefully and still parses"
)

bgc_smoke_section("bgc_cached_compute() hash-based reuse")

bgc_dr_cache_clear()
bgc_smoke_assert(
  bgc_dr_cache_size() == 0L,
  "cache clears to size 0"
)

counter_env <- new.env(parent = emptyenv())
counter_env$calls <- 0L
mk <- function() {
  counter_env$calls <- counter_env$calls + 1L
  counter_env$calls
}

r1 <- bgc_cached_compute(key = list("demo", iris), compute = mk)
r2 <- bgc_cached_compute(key = list("demo", iris), compute = mk)
bgc_smoke_assert(
  counter_env$calls == 1L && identical(r1, 1L) && identical(r2, 1L),
  "second call with same key hits cache and skips compute"
)
bgc_smoke_assert(
  bgc_dr_cache_size() == 1L,
  "cache size is 1 after a hit-and-miss sequence on the same key"
)

r3 <- bgc_cached_compute(key = list("demo", iris, seed = 42), compute = mk)
bgc_smoke_assert(
  counter_env$calls == 2L && identical(r3, 2L) && bgc_dr_cache_size() == 2L,
  "different key (seed param) triggers recompute and grows cache"
)

mutated <- iris
mutated$Sepal.Length[1] <- 999
r4 <- bgc_cached_compute(key = list("demo", mutated), compute = mk)
bgc_smoke_assert(
  counter_env$calls == 3L && identical(r4, 3L) && bgc_dr_cache_size() == 3L,
  "mutating the data payload invalidates the cache key"
)

bgc_dr_cache_clear()
bgc_smoke_assert(
  bgc_dr_cache_size() == 0L,
  "cache clears back to size 0 after teardown"
)

bgc_smoke_section("bgc_session_upload_cache() session-level sharing")

mk_fake_session <- function() {
  s <- new.env(parent = emptyenv())
  s$userData <- new.env(parent = emptyenv())
  s$rootScope <- function() s
  s
}

null_rv <- bgc_session_upload_cache(NULL)
bgc_smoke_assert(
  shiny::is.reactivevalues(null_rv) || inherits(null_rv, "reactiveVal") ||
    is.function(null_rv),
  "bgc_session_upload_cache(NULL) returns a reactiveVal-shaped object"
)
shiny::isolate(null_rv(list(name = "fallback.csv")))
bgc_smoke_assert(
  identical(shiny::isolate(null_rv())$name, "fallback.csv"),
  "NULL-session reactiveVal is read/write"
)

sess <- mk_fake_session()
rv1 <- bgc_session_upload_cache(sess)
rv2 <- bgc_session_upload_cache(sess)
bgc_smoke_assert(
  identical(rv1, rv2),
  "same session returns same reactiveVal instance"
)

shiny::isolate(rv1(list(
  name = "shared.csv",
  datapath = "/tmp/shared.csv",
  header = TRUE,
  separator = ",",
  quote = "\"",
  data = iris,
  row_names = FALSE,
  timestamp = Sys.time()
)))
bgc_smoke_assert(
  identical(shiny::isolate(rv2())$name, "shared.csv"),
  "write via one handle is visible via another (cross-module sharing)"
)
bgc_smoke_assert(
  is.data.frame(shiny::isolate(rv2())$data) &&
    nrow(shiny::isolate(rv2())$data) == nrow(iris),
  "session cache preserves the parsed data frame"
)

sess2 <- mk_fake_session()
rv_other <- bgc_session_upload_cache(sess2)
bgc_smoke_assert(
  is.null(shiny::isolate(rv_other())),
  "different sessions get isolated reactiveVals"
)

bgc_smoke_report()
