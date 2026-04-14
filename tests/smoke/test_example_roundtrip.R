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
bgc_smoke_report()
