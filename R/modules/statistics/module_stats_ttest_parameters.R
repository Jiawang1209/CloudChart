stats_parameters_ttest_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "group_var", "Group variable (2 levels)")),
      column(width = 3, bgc_column_select(id, "value_var", "Value variable (numeric)")),
      column(width = 3,
             prettyRadioButtons(NS(id, "alternative"),
                                label = "Alternative",
                                choiceNames = c("Two-sided","Less","Greater"),
                                choiceValues = c("two.sided","less","greater"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             prettyRadioButtons(NS(id, "var_equal"),
                                label = "Equal Variance",
                                choiceNames = c("Welch","Student"),
                                choiceValues = c("no","yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    fluidRow(
      align = "center",
      column(width = 4,
             sliderInput(NS(id, "conf_level"),
                         "Confidence Level",
                         value = 0.95, min = 0.80, max = 0.99, step = 0.01))
    )
  )
}
