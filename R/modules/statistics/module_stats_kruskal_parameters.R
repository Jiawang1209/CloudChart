stats_parameters_kruskal_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6, bgc_column_select(id, "group_var", "Group variable")),
      column(width = 6, bgc_column_select(id, "value_var", "Value variable (numeric)"))
    ),
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "post_hoc"),
                                label = "Pairwise Post-hoc",
                                choiceNames = c("None","Pairwise Wilcoxon (BH-adjusted)"),
                                choiceValues = c("none","pairwise"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    )
  )
}
