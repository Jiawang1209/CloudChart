stats_parameters_chisq_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6, bgc_column_select(id, "row_var", "Row variable (categorical)")),
      column(width = 6, bgc_column_select(id, "col_var", "Column variable (categorical)"))
    ),
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "correct"),
                                label = "Continuity Correction",
                                choiceNames = c("Yes","No"),
                                choiceValues = c("yes","no"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 6,
             prettyRadioButtons(NS(id, "simulate_p"),
                                label = "Monte Carlo p-value",
                                choiceNames = c("No","Yes (B=2000)"),
                                choiceValues = c("no","yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    )
  )
}
