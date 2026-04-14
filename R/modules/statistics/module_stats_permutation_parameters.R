stats_parameters_permutation_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "group_var", "Group variable (2 levels)")),
      column(width = 4, bgc_column_select(id, "value_var", "Value variable (numeric)")),
      column(width = 4,
             prettyRadioButtons(NS(id, "alternative"),
                                label = "Alternative",
                                choiceNames = c("Two-sided","Less","Greater"),
                                choiceValues = c("two.sided","less","greater"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    fluidRow(
      align = "center",
      column(width = 6, sliderInput(NS(id, "n_perm"), "Permutations",
                                    value = 5000, min = 200, max = 50000, step = 100)),
      column(width = 6, numericInput(NS(id, "seed"), "Seed", value = 42, step = 1))
    )
  )
}
