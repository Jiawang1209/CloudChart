stats_parameters_fisher_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6, bgc_column_select(id, "row_var", "Row variable (categorical)")),
      column(width = 6, bgc_column_select(id, "col_var", "Column variable (categorical)"))
    ),
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "alternative"),
                                label = "Alternative (2x2 only)",
                                choiceNames = c("Two-sided","Less","Greater"),
                                choiceValues = c("two.sided","less","greater"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 6,
             sliderInput(NS(id, "conf_level"),
                         "Confidence Level",
                         value = 0.95, min = 0.80, max = 0.99, step = 0.01))
    )
  )
}
