data_tools_parameters_pivot_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 12,
             prettyRadioButtons(NS(id, "direction"),
                                label = "Direction",
                                choiceNames = c("Wider (long to wide)","Longer (wide to long)"),
                                choiceValues = c("wider","longer"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    tags$div(
      style = "font-weight: 600; color: #1f3b5b;",
      "For 'Wider':"
    ),
    fluidRow(
      align = "center",
      column(width = 6, bgc_column_select(id, "names_from", "names_from column (becomes new column names)")),
      column(width = 6, bgc_column_select(id, "values_from", "values_from column (fills the cells)"))
    ),
    tags$hr(),
    tags$div(
      style = "font-weight: 600; color: #1f3b5b;",
      "For 'Longer':"
    ),
    fluidRow(
      align = "center",
      column(width = 6, bgc_multi_column_select(id, "pivot_cols", "Columns to pivot into long form")),
      column(width = 3, textInput(NS(id, "names_to"), "names_to (new key column)", value = "name")),
      column(width = 3, textInput(NS(id, "values_to"), "values_to (new value column)", value = "value"))
    )
  )
}
