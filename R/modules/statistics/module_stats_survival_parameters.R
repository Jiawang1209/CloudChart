stats_parameters_survival_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "time_var",   "Time variable (numeric)")),
      column(width = 4, bgc_column_select(id, "status_var", "Status variable (0 = censored, 1 = event)")),
      column(width = 4, bgc_column_select(id, "group_var",  "Group variable (optional)"))
    ),
    fluidRow(
      align = "center",
      column(
        width = 6,
        sliderInput(
          NS(id, "conf_level"),
          "Confidence Level",
          value = 0.95, min = 0.80, max = 0.99, step = 0.01
        )
      ),
      column(
        width = 6,
        prettyRadioButtons(
          NS(id, "rho"),
          label = "Log-rank Weighting",
          choiceNames  = c("Log-rank (rho=0)", "Peto-Peto (rho=1)"),
          choiceValues = c("0", "1"),
          icon = icon("check"),
          animation = "tada",
          inline = TRUE
        )
      )
    )
  )
}
