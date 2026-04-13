data_tools_parameters_join_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(
        width = 6,
        fileInput(
          NS(id, "right_file"),
          "Right table (CSV / TSV / XLSX)",
          accept = c(".csv", ".tsv", ".txt", ".xlsx"),
          placeholder = "Upload the second table"
        )
      ),
      column(
        width = 6,
        prettyRadioButtons(
          NS(id, "right_separator"),
          label = "Right table separator",
          choiceNames  = c("Comma", "Tab", "Semicolon", "Auto (xlsx)"),
          choiceValues = c(",", "\t", ";", "xlsx2"),
          icon = icon("check"),
          animation = "tada",
          inline = TRUE
        )
      )
    ),
    fluidRow(
      align = "center",
      column(width = 6, bgc_column_select(id, "left_key",  "Left key column")),
      column(width = 6, bgc_column_select(id, "right_key", "Right key column"))
    ),
    fluidRow(
      align = "center",
      column(
        width = 12,
        prettyRadioButtons(
          NS(id, "join_type"),
          label = "Join Type",
          choiceNames  = c("Inner", "Left", "Right", "Full (outer)"),
          choiceValues = c("inner", "left", "right", "full"),
          icon = icon("check"),
          animation = "tada",
          inline = TRUE
        )
      )
    )
  )
}
