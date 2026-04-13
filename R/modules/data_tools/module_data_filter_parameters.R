data_tools_parameters_filter_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "filter_column", "Column to filter")),
      column(width = 4,
             prettyRadioButtons(NS(id, "filter_operator"),
                                label = "Operator",
                                choiceNames = c("==","!=",">",">=","<","<=","contains","is NA","not NA"),
                                choiceValues = c("eq","neq","gt","gte","lt","lte","contains","is_na","not_na"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 4, textInput(NS(id, "filter_value"), "Value", value = ""))
    ),
    fluidRow(
      align = "center",
      column(width = 4,
             prettyRadioButtons(NS(id, "case_sensitive"),
                                label = "Case Sensitive (contains only)",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("no","yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    )
  )
}
