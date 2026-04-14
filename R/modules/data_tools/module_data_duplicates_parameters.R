data_tools_parameters_duplicates_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "key_mode"),
                                label = "Key columns",
                                choiceNames = c("All columns", "Selected columns"),
                                choiceValues = c("all", "selected"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 6,
             prettyRadioButtons(NS(id, "result_mode"),
                                label = "Result",
                                choiceNames = c("Duplicates only", "Drop duplicates", "Flag column"),
                                choiceValues = c("duplicates", "drop", "flag"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 8, bgc_multi_column_select(id, "key_cols", "Key columns")),
      column(width = 4,
             prettyRadioButtons(NS(id, "include_first"),
                                label = "Include first occurrence",
                                choiceNames = c("Yes", "No"),
                                choiceValues = c("yes", "no"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 12,
             textInput(NS(id, "flag_col"), "Flag column name (for 'Flag column' mode)", value = "is_duplicate"))
    )
  )
}
