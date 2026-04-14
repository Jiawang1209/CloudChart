data_tools_parameters_separate_unite_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "operation"),
                                label = "Operation",
                                choiceNames = c("Separate","Unite"),
                                choiceValues = c("separate","unite"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 6,
             prettyRadioButtons(NS(id, "remove_source"),
                                label = "Remove source columns",
                                choiceNames = c("Yes","No"),
                                choiceValues = c("yes","no"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "separate_col", "Column to separate")),
      column(width = 4, textInput(NS(id, "separate_into"), "New columns (comma-separated)", value = "part1, part2")),
      column(width = 4, textInput(NS(id, "separator"), "Separator (regex)", value = "_"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 4, bgc_multi_column_select(id, "unite_cols", "Columns to unite")),
      column(width = 4, textInput(NS(id, "unite_into"), "New column name", value = "combined")),
      column(width = 4, textInput(NS(id, "unite_sep"), "Join separator", value = "_"))
    )
  )
}
