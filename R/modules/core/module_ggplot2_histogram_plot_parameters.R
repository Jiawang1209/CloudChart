ggplot2_parameters_histogram_plot_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      # Set x Axis Variable
      column(width = 3, textInput(NS(id, "x_axis"), "Set x axis variable", value = NULL)),
      # Set bin value
      column(width = 3, sliderInput(NS(id, "bins_width"), "Bins Value", value = 30, min = 0, max = 100))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set alpha
      column(width = 2, sliderInput(NS(id, "alpha"), "Density Alpha", value = 0.6, min = 0, max = 1)),
      # Set fill color
      column(width = 2, colourInput(NS(id, "fill_color"), "Set Line Color", value = "#69b3a2")),
      # Set line color
      column(width = 2, colourInput(NS(id, "line_color"), "Set Line Color", value = "#e9ecef")),
      # Set line width
      column(width = 2, sliderInput(NS(id, "line_width"), "Line Width", value = 0.75, min = 0, max = 2, step = 0.25)),
      # Set label size
      column(width = 2, sliderInput(NS(id, "label_size"), "Label Size", value = 15, min = 0, max = 50))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 2, textInput(NS(id, "plot_subtitle"), "Set plot subtitle",value = NULL)),
        column(width = 2, textInput(NS(id, "x_axis_Title"), "Set x axis title",value = NULL)),
        column(width = 2, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = NULL)),
        column(width = 2, numericRangeInput(NS(id, "x_limite"), "Set x axis limites", value = c(NA, NA))),
        column(width = 2, numericRangeInput(NS(id, "y_limite"), "Set y axis limites", value = c(NA, NA)))
      ),
      tags$hr(),
      prettyRadioButtons(inputId = NS(id, "theme_choose"),
                         label = "Theme Choose:",
                         choiceNames = c("default","theme:bw","theme:classic","theme:clean","theme:GraphPadPrism",
                                         "theme:excel", "theme:stata","theme:economist","theme:GoogleDocs","theme:WallStreetJournal"),
                         choiceValues = c("theme_grey", "theme_bw", "theme_classic","theme_clean", "theme_prism", "theme_excel_new",
                                          "theme_stata", "theme_economist_white","theme_gdocs", "theme_wsj"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE
      )
    )
  )
}