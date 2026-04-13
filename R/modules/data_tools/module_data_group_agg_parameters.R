data_tools_parameters_group_agg_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6, bgc_multi_column_select(id, "group_columns", "Group columns (>= 1)")),
      column(width = 6, bgc_multi_column_select(id, "value_columns", "Numeric value columns (>= 1)"))
    ),
    fluidRow(
      align = "center",
      column(
        width = 12,
        checkboxGroupButtons(
          inputId = NS(id, "agg_functions"),
          label = "Aggregation Functions",
          choices = c(
            "n"      = "n",
            "mean"   = "mean",
            "median" = "median",
            "sum"    = "sum",
            "sd"     = "sd",
            "var"    = "var",
            "min"    = "min",
            "max"    = "max"
          ),
          selected = c("n", "mean", "sd"),
          status = "primary",
          checkIcon = list(yes = icon("check"))
        )
      )
    )
  )
}
