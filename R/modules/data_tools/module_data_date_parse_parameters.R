data_tools_parameters_date_parse_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "date_col", "Date column")),
      column(width = 4, textInput(NS(id, "date_format"), "Format string", value = "%Y-%m-%d")),
      column(width = 4, textInput(NS(id, "new_col"), "Parsed column name", value = "date_parsed"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 12,
             checkboxGroupInput(
               inputId = NS(id, "extract_parts"),
               label = "Extract parts",
               choices = c("year","quarter","month","day","weekday","week"),
               selected = c("year","month","day"),
               inline = TRUE
             ))
    )
  )
}
