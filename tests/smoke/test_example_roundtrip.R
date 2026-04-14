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

bgc_smoke_report()
