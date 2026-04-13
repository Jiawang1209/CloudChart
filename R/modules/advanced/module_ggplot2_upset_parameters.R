ggplot2_parameters_upset_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "value_column", "Value column (unique members)")),
      column(width = 4, bgc_column_select(id, "group_column", "Group column (defines sets)")),
      column(width = 4, sliderInput(NS(id, "min_size"), "Min Intersection Size", value = 1, min = 1, max = 100, step = 1))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 3,
             prettyRadioButtons(NS(id, "sort_intersections"),
                                label = "Sort Intersections",
                                choiceNames = c("By Size","Ratio","Degree","None"),
                                choiceValues = c("cardinality","ratio","degree","none"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             prettyRadioButtons(NS(id, "sort_sets"),
                                label = "Sort Sets",
                                choiceNames = c("Ascending","Descending","None"),
                                choiceValues = c("ascending","descending","none"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3, colourInput(NS(id, "bar_fill"), "Bar Fill", value = "#2C3E50")),
      column(width = 3, sliderInput(NS(id, "label_size"), "Label Size", value = 14, min = 5, max = 40))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 4, textInput(NS(id, "plot_title"), "Set plot title", value = NULL)),
        column(width = 4, textInput(NS(id, "plot_subtitle"), "Set plot subtitle", value = NULL))
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
