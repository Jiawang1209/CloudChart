ggplot2_parameters_venn_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "value_column", "Value column (each row is a member)")),
      column(width = 4, bgc_column_select(id, "group_column", "Group column (defines 2-7 sets)")),
      column(width = 4,
             prettyRadioButtons(NS(id, "count_style"),
                                label = "Show Counts",
                                choiceNames = c("Count","Percent","Both","None"),
                                choiceValues = c("count","percent","both","none"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 2, sliderInput(NS(id, "set_label_size"), "Set Label Size", value = 6, min = 1, max = 20, step = 0.5)),
      column(width = 2, sliderInput(NS(id, "cell_label_size"), "Cell Label Size", value = 5, min = 1, max = 20, step = 0.5)),
      column(width = 2, sliderInput(NS(id, "edge_width"), "Edge Width", value = 1, min = 0, max = 4, step = 0.1)),
      column(width = 2, colourInput(NS(id, "edge_color"), "Edge Color", value = "#2C3E50")),
      column(width = 2, colourInput(NS(id, "low_color"), "Low Fill", value = "#E8F4F8")),
      column(width = 2, colourInput(NS(id, "high_color"), "High Fill", value = "#1C6EA4"))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 3, textInput(NS(id, "plot_title"), "Set plot title", value = NULL)),
        column(width = 3, textInput(NS(id, "plot_subtitle"), "Set plot subtitle", value = NULL)),
        column(width = 3, sliderInput(NS(id, "label_size"), "Base Label Size", value = 15, min = 5, max = 50))
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
