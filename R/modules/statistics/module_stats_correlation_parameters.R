stats_parameters_correlation_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 12, bgc_multi_column_select(id, "numeric_columns", "Numeric columns (select >= 2)"))
    ),
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "cor_method"),
                                label = "Method",
                                choiceNames = c("Pearson","Spearman","Kendall"),
                                choiceValues = c("pearson","spearman","kendall"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 6,
             prettyRadioButtons(NS(id, "adjust_method"),
                                label = "p-value Adjust",
                                choiceNames = c("None","Bonferroni","BH","Holm"),
                                choiceValues = c("none","bonferroni","BH","holm"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    )
  )
}
