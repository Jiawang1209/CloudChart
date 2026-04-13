stats_parameters_shapiro_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 12, bgc_multi_column_select(id, "target_columns", "Numeric columns to test (select >= 1)"))
    ),
    fluidRow(
      align = "center",
      column(width = 6, bgc_column_select(id, "group_var", "Group variable (optional, tests each group)")),
      column(width = 6,
             sliderInput(NS(id, "alpha"),
                         "Significance Level (alpha)",
                         value = 0.05, min = 0.01, max = 0.10, step = 0.01))
    )
  )
}
