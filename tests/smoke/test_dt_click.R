source("tests/smoke/_helpers.R")
bgc_smoke_bootstrap()

bgc_smoke_section("file_upload module server round-trip (in-process)")

dirty_csv_path <- tempfile(fileext = ".csv")
on.exit(unlink(dirty_csv_path), add = TRUE, after = FALSE)

writeLines(
  c(
    "id,,label ,all_na,dup,dup",
    "1,10,x,,100,1000",
    "2,20,y,,200,2000",
    "3,30,z,,300,3000",
    "4,40,w,,400,4000"
  ),
  dirty_csv_path
)

dirty_raw <- utils::read.csv(
  dirty_csv_path,
  header = TRUE,
  sep = ",",
  quote = "\"",
  check.names = FALSE
)

bgc_smoke_assert(
  anyDuplicated(colnames(dirty_raw)) > 0L ||
    any(!nzchar(colnames(dirty_raw))) ||
    any(vapply(dirty_raw, function(col) all(is.na(col)), logical(1))),
  "dirty fixture actually has pathological columns before sanitize"
)

fake_upload <- list(
  name = basename(dirty_csv_path),
  datapath = dirty_csv_path
)

shiny::testServer(
  file_upload_Server,
  args = list(),
  {
    session$setInputs(
      file_upload = fake_upload,
      file_header = TRUE,
      file_separator = "auto",
      file_quote = "\"",
      submit_file = 1
    )

    frame <- df()

    bgc_smoke_assert(
      is.data.frame(frame),
      "df() returns a data.frame after submit_file click"
    )
    bgc_smoke_assert(
      all(nzchar(colnames(frame))),
      sprintf("sanitized frame has no blank column names (got: %s)",
              paste(colnames(frame), collapse = ","))
    )
    bgc_smoke_assert(
      anyDuplicated(colnames(frame)) == 0L,
      sprintf("sanitized frame has unique column names (got: %s)",
              paste(colnames(frame), collapse = ","))
    )
    bgc_smoke_assert(
      !("all_na" %in% colnames(frame)),
      "sanitized frame drops all-NA columns"
    )
    bgc_smoke_assert(
      nrow(frame) == 4L,
      sprintf("sanitized frame keeps all 4 rows (got %d)", nrow(frame))
    )

    rendered_summary <- output$file_summary
    bgc_smoke_assert(
      !is.null(rendered_summary),
      "file_summary renderUI produces output"
    )
    summary_text <- paste(capture.output(print(rendered_summary)), collapse = " ")
    bgc_smoke_assert(
      grepl("Rows: 4", summary_text, fixed = TRUE),
      sprintf("file_summary reports 4 rows (head: %s)",
              substr(summary_text, 1, 180))
    )
    bgc_smoke_assert(
      !grepl("Upload failed", summary_text, fixed = TRUE),
      "file_summary does not fall back to the error panel for a sanitized frame"
    )

    rendered_output <- output$file_output
    bgc_smoke_assert(
      !is.null(rendered_output),
      "file_output DT renderer produces a non-null value"
    )
  }
)

bgc_smoke_section("DT server-side filter path on sanitized frame")

sanitized <- sanitize_uploaded_table(dirty_raw)

dt_build_ok <- tryCatch(
  {
    DT::datatable(
      sanitized,
      rownames = FALSE,
      options = list(
        pageLength = 10,
        lengthMenu = c(10, 25, 50, 100),
        scrollX = TRUE,
        dom = "lftip"
      )
    )
    TRUE
  },
  error = function(e) { cat("    DT build error: ", conditionMessage(e), "\n", sep = ""); FALSE },
  warning = function(w) { cat("    DT build warning: ", conditionMessage(w), "\n", sep = ""); FALSE }
)
bgc_smoke_assert(
  isTRUE(dt_build_ok),
  "DT::datatable() builds the same options file_upload_Server uses"
)

if (exists("dataTablesFilter", where = asNamespace("DT"), inherits = FALSE)) {
  filter_fn <- get("dataTablesFilter", envir = asNamespace("DT"))

  cols <- lapply(seq_len(ncol(sanitized)), function(i) {
    list(
      data = as.character(i - 1L),
      name = "",
      searchable = "true",
      orderable = "true",
      search = list(value = "", regex = "false")
    )
  })
  names(cols) <- as.character(seq_along(cols) - 1L)

  fake_request <- list(
    draw = "1",
    start = "0",
    length = "10",
    escape = "true",
    search = list(value = "", regex = "false", smart = "true",
                  caseInsensitive = "true"),
    order = list(`0` = list(column = "0", dir = "asc")),
    columns = cols
  )

  filter_ok <- tryCatch(
    {
      res <- filter_fn(sanitized, fake_request)
      is.list(res) || is.character(res)
    },
    error = function(e) { cat("    filter error: ", conditionMessage(e), "\n", sep = ""); FALSE },
    warning = function(w) { cat("    filter warning: ", conditionMessage(w), "\n", sep = ""); FALSE }
  )
  bgc_smoke_assert(
    isTRUE(filter_ok),
    "DT:::dataTablesFilter() tolerates sanitized pathological frame (guards searchable[j])"
  )

  malformed_request <- fake_request
  malformed_request$escape <- NULL
  malformed_filter_error <- tryCatch(
    {
      filter_fn(sanitized, malformed_request)
      FALSE
    },
    error = function(e) {
      grepl("length zero", conditionMessage(e), fixed = TRUE)
    },
    warning = function(w) FALSE
  )
  bgc_smoke_assert(
    isTRUE(malformed_filter_error),
    "reproduces the 'argument is of length zero' class error when request is missing q$escape (regression probe)"
  )
} else {
  cat("  SKIP DT:::dataTablesFilter not exported in this DT version\n")
}

bgc_smoke_section("bgc_preview_datatable helper")

clean_preview <- tryCatch(
  bgc_preview_datatable(iris, digits = 4),
  error = function(e) { cat("    helper error: ", conditionMessage(e), "\n", sep = ""); NULL }
)
bgc_smoke_assert(
  !is.null(clean_preview) && inherits(clean_preview, "datatables"),
  "bgc_preview_datatable(iris) returns a DT datatables htmlwidget"
)

dirty_preview <- tryCatch(
  bgc_preview_datatable(dirty_raw, digits = 4),
  error = function(e) { cat("    dirty helper error: ", conditionMessage(e), "\n", sep = ""); NULL }
)
bgc_smoke_assert(
  !is.null(dirty_preview) && inherits(dirty_preview, "datatables"),
  "bgc_preview_datatable(dirty_raw) sanitizes in-line and still builds"
)

err_dt <- bgc_preview_error_dt("boom")
bgc_smoke_assert(
  inherits(err_dt, "datatables"),
  "bgc_preview_error_dt returns a datatables htmlwidget for error fallback"
)

bgc_smoke_report()
