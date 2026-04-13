stats_parameters_anova_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "group_var", "Group variable")),
      column(width = 4, bgc_column_select(id, "value_var", "Value variable (numeric)")),
      column(width = 4,
             prettyRadioButtons(NS(id, "post_hoc"),
                                label = "Post-hoc Test",
                                choiceNames = c("None","Tukey HSD"),
                                choiceValues = c("none","tukey"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    )
  )
}
