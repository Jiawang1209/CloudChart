stats_parameters_logreg_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6, bgc_column_select(id, "response_var", "Response variable (binary / 2-level)")),
      column(width = 6, bgc_multi_column_select(id, "predictor_vars", "Predictor variables (>= 1)"))
    ),
    fluidRow(
      align = "center",
      column(
        width = 6,
        prettyRadioButtons(
          NS(id, "intercept"),
          label = "Intercept",
          choiceNames  = c("Include", "Exclude"),
          choiceValues = c("yes", "no"),
          icon = icon("check"),
          animation = "tada",
          inline = TRUE
        )
      ),
      column(
        width = 6,
        sliderInput(
          NS(id, "conf_level"),
          "Confidence Level",
          value = 0.95, min = 0.80, max = 0.99, step = 0.01
        )
      )
    )
  )
}
