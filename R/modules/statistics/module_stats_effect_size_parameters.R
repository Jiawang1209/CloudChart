stats_parameters_effect_size_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(
        width = 12,
        prettyRadioButtons(
          NS(id, "method"),
          label = "Effect Size Method",
          choiceNames  = c(
            "Cohen's d (2 groups, numeric outcome)",
            "Eta-squared (ANOVA, >=2 groups, numeric outcome)",
            "Cramer's V (two categorical variables)"
          ),
          choiceValues = c("cohen_d", "eta_sq", "cramers_v"),
          icon = icon("check"),
          animation = "tada",
          inline = FALSE
        )
      )
    ),
    conditionalPanel(
      condition = sprintf("input['%s'] != 'cramers_v'", NS(id, "method")),
      fluidRow(
        align = "center",
        column(width = 6, bgc_column_select(id, "group_var", "Group variable (categorical)")),
        column(width = 6, bgc_column_select(id, "value_var", "Value variable (numeric)"))
      )
    ),
    conditionalPanel(
      condition = sprintf("input['%s'] == 'cramers_v'", NS(id, "method")),
      fluidRow(
        align = "center",
        column(width = 6, bgc_column_select(id, "row_var", "Row variable (categorical)")),
        column(width = 6, bgc_column_select(id, "col_var", "Column variable (categorical)"))
      )
    )
  )
}
