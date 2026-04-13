data_tools_export_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    prepared <- eventReactive(input$apply_transform, {
      data <- df()
      validate(need(!is.null(data) && nrow(data) > 0, "Upload a non-empty data table first."))
      if (identical(input$export_format, "xlsx")) {
        validate(
          need(
            requireNamespace("writexl", quietly = TRUE),
            "Exporting to XLSX requires the 'writexl' package. Install it with install.packages('writexl')."
          )
        )
      }
      data
    })

    output$transform_preview <- renderTable({
      validate(need(input$apply_transform > 0, "Click 'Apply Transform' to prepare the export."))
      head(prepared(), 20)
    }, digits = 4)

    output$transform_summary <- renderUI({
      validate(need(input$apply_transform > 0, "Click 'Apply Transform' to prepare the export."))
      data <- prepared()
      format_label <- switch(
        input$export_format,
        csv  = "CSV (.csv)",
        tsv  = "TSV (.tsv)",
        xlsx = "Excel (.xlsx)",
        rds  = "RDS (.rds)",
        input$export_format
      )
      tags$div(
        style = "padding: 12px 14px; border: 1px solid #d7dee7; border-radius: 12px; background: #f8fafc;",
        tags$div(
          style = "font-weight: 600; color: #1f3b5b; margin-bottom: 8px;",
          "Export Summary"
        ),
        tags$p(
          style = "margin-bottom: 0;",
          sprintf(
            "Rows: %d | Columns: %d | Format: %s | Click 'Download CSV' to save.",
            nrow(data),
            ncol(data),
            format_label
          )
        )
      )
    })

    output$download_transformed <- downloadHandler(
      filename = function() {
        ext <- switch(
          input$export_format,
          csv  = ".csv",
          tsv  = ".tsv",
          xlsx = ".xlsx",
          rds  = ".rds",
          ".txt"
        )
        paste0("exported_data_", Sys.Date(), ext)
      },
      content = function(file) {
        data <- prepared()
        row_names <- identical(input$include_rownames, "yes")
        switch(
          input$export_format,
          csv  = write.csv(data, file, row.names = row_names),
          tsv  = write.table(data, file, sep = "\t",
                             row.names = row_names, quote = FALSE),
          xlsx = writexl::write_xlsx(data, path = file),
          rds  = saveRDS(
            data,
            file = file,
            compress = identical(input$rds_compress, "yes")
          ),
          stop("Unknown export format: ", input$export_format)
        )
      }
    )
  })
}
