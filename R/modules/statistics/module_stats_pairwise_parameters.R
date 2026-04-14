stats_parameters_pairwise_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "group_var", "Group variable")),
      column(width = 4, bgc_column_select(id, "value_var", "Value variable (numeric)")),
      column(width = 4,
             prettyRadioButtons(NS(id, "test_kind"),
                                label = "Pairwise test",
                                choiceNames = c("t-test","Wilcoxon"),
                                choiceValues = c("t","wilcox"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "p_adjust"),
                                label = "p adjustment",
                                choiceNames = c("holm","BH","bonferroni","none"),
                                choiceValues = c("holm","BH","bonferroni","none"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 6,
             prettyRadioButtons(NS(id, "pool_sd"),
                                label = "Pool SD (t-test only)",
                                choiceNames = c("Yes","No"),
                                choiceValues = c("yes","no"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    )
  )
}
