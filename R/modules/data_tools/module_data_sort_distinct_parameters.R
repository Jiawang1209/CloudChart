data_tools_parameters_sort_distinct_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6, bgc_multi_column_select(id, "sort_columns", "Sort by columns (order matters)")),
      column(width = 6,
             prettyRadioButtons(NS(id, "sort_order"),
                                label = "Sort Order",
                                choiceNames = c("Ascending","Descending"),
                                choiceValues = c("asc","desc"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "distinct_mode"),
                                label = "Deduplicate",
                                choiceNames = c("Keep all","Distinct on all columns","Distinct on selected columns"),
                                choiceValues = c("none","all","selected"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = FALSE)),
      column(width = 6, bgc_multi_column_select(id, "distinct_columns", "Columns for distinct (selected mode)"))
    )
  )
}
