stats_parameters_mixed_effects_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "response_var", "Response (numeric)")),
      column(width = 4, bgc_multi_column_select(id, "fixed_vars", "Fixed effects")),
      column(width = 4, bgc_column_select(id, "random_var", "Random effect (grouping)"))
    ),
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "reml"),
                                label = "Estimation",
                                choiceNames = c("REML","ML"),
                                choiceValues = c("yes","no"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 6,
             prettyRadioButtons(NS(id, "include_intercept"),
                                label = "Random intercept only",
                                choiceNames = c("Yes (1 | g)","Random slope on first fixed (x | g)"),
                                choiceValues = c("intercept","slope"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    )
  )
}
