data_tools_parameters_summarize_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6, bgc_multi_column_select(id, "group_columns", "Group by columns")),
      column(width = 6, bgc_multi_column_select(id, "value_columns", "Value columns (numeric)"))
    ),
    fluidRow(
      align = "center",
      column(
        width = 12,
        prettyRadioButtons(NS(id, "agg_fun"),
                           label = "Aggregate Function",
                           choiceNames = c("Mean","Median","Sum","Min","Max","SD","Count"),
                           choiceValues = c("mean","median","sum","min","max","sd","count"),
                           icon = icon("check"),
                           animation = "tada",
                           inline = TRUE)
      )
    )
  )
}
