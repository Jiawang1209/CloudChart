data_tools_parameters_missing_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 6, bgc_multi_column_select(id, "target_columns", "Target columns (empty = all)"))
    ),
    fluidRow(
      align = "center",
      column(width = 6,
             prettyRadioButtons(NS(id, "strategy"),
                                label = "Strategy",
                                choiceNames = c(
                                  "Drop rows with any NA",
                                  "Drop rows with all NA",
                                  "Fill with mean (numeric)",
                                  "Fill with median (numeric)",
                                  "Fill with zero (numeric)",
                                  "Fill with custom value"
                                ),
                                choiceValues = c("drop_any","drop_all","mean","median","zero","custom"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = FALSE)),
      column(width = 6, textInput(NS(id, "custom_value"), "Custom fill value (for 'custom' strategy)", value = ""))
    )
  )
}
