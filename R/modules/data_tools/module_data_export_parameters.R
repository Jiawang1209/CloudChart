data_tools_parameters_export_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(
        width = 12,
        prettyRadioButtons(
          NS(id, "export_format"),
          label = "Export Format",
          choiceNames  = c("CSV (.csv)", "TSV (.tsv)", "Excel (.xlsx)", "RDS (.rds)"),
          choiceValues = c("csv", "tsv", "xlsx", "rds"),
          icon = icon("check"),
          animation = "tada",
          inline = TRUE
        )
      )
    ),
    fluidRow(
      align = "center",
      column(
        width = 6,
        prettyRadioButtons(
          NS(id, "include_rownames"),
          label = "Include Row Names",
          choiceNames  = c("No", "Yes"),
          choiceValues = c("no", "yes"),
          icon = icon("check"),
          animation = "tada",
          inline = TRUE
        )
      ),
      column(
        width = 6,
        prettyRadioButtons(
          NS(id, "rds_compress"),
          label = "RDS Compression (rds only)",
          choiceNames  = c("Yes", "No"),
          choiceValues = c("yes", "no"),
          icon = icon("check"),
          animation = "tada",
          inline = TRUE
        )
      )
    )
  )
}
