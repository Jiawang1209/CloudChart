stats_parameters_posthoc_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6, bgc_column_select(id, "group_var", "Group variable (categorical)")),
      column(width = 6, bgc_column_select(id, "value_var", "Value variable (numeric)"))
    ),
    fluidRow(
      align = "center",
      column(
        width = 6,
        prettyRadioButtons(
          NS(id, "method"),
          label = "Post-hoc Method",
          choiceNames  = c("Tukey HSD (after ANOVA)", "Pairwise t-test", "Pairwise Wilcoxon"),
          choiceValues = c("tukey", "pairwise_t", "pairwise_wilcox"),
          icon = icon("check"),
          animation = "tada",
          inline = FALSE
        )
      ),
      column(
        width = 6,
        prettyRadioButtons(
          NS(id, "p_adjust"),
          label = "p-value Adjustment",
          choiceNames  = c("Holm", "BH (FDR)", "Bonferroni", "None"),
          choiceValues = c("holm", "BH", "bonferroni", "none"),
          icon = icon("check"),
          animation = "tada",
          inline = TRUE
        )
      )
    )
  )
}
