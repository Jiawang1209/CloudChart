ggplot2_parameters_dumbbell_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "y_axis", "Category variable (y)")),
      column(width = 3, bgc_column_select(id, "x_start", "Start value (x1)")),
      column(width = 3, bgc_column_select(id, "x_end", "End value (x2)")),
      column(width = 3,
             prettyRadioButtons(NS(id, "sort_by"),
                                label = "Sort Categories",
                                choiceNames = c("None","By Start","By End","By Difference"),
                                choiceValues = c("none","start","end","diff"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 2, colourInput(NS(id, "start_color"), "Start Color", value = "#4A6FA5")),
      column(width = 2, colourInput(NS(id, "end_color"), "End Color", value = "#E94E5B")),
      column(width = 2, colourInput(NS(id, "segment_color"), "Segment Color", value = "#B0B0B0")),
      column(width = 2, sliderInput(NS(id, "point_size"), "Point Size", value = 5, min = 0, max = 20)),
      column(width = 2, sliderInput(NS(id, "segment_size"), "Segment Width", value = 2, min = 0, max = 8, step = 0.25)),
      column(width = 2, sliderInput(NS(id, "label_size"), "Label Size", value = 15, min = 5, max = 40))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 3,
             prettyRadioButtons(NS(id, "show_diff"),
                                label = "Show Difference Labels",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3, textInput(NS(id, "start_label"), "Start Legend Label", value = "Start")),
      column(width = 3, textInput(NS(id, "end_label"), "End Legend Label", value = "End")),
      column(width = 3, sliderInput(NS(id, "point_alpha"), "Point Alpha", value = 1, min = 0, max = 1, step = 0.05))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 2, textInput(NS(id, "plot_title"), "Set plot title", value = NULL)),
        column(width = 2, textInput(NS(id, "plot_subtitle"), "Set plot subtitle", value = NULL)),
        column(width = 2, textInput(NS(id, "x_axis_Title"), "Set x axis title", value = NULL)),
        column(width = 2, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = NULL)),
        column(width = 2, numericRangeInput(NS(id, "x_limite"), "Set x axis limits", value = c(NA, NA))),
        column(width = 2, numericRangeInput(NS(id, "y_limite"), "Set y axis limits", value = c(NA, NA)))
      ),
      tags$hr(),
      prettyRadioButtons(inputId = NS(id, "theme_choose"),
                         label = "Theme Choose:",
                         choiceNames = c("default","theme:bw","theme:classic","theme:clean","theme:GraphPadPrism",
                                         "theme:excel","theme:stata","theme:economist","theme:GoogleDocs","theme:WallStreetJournal"),
                         choiceValues = c("theme_grey","theme_bw","theme_classic","theme_clean","theme_prism","theme_excel_new",
                                          "theme_stata","theme_economist_white","theme_gdocs","theme_wsj"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE)
    )
  )
}
