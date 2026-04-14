ggplot2_parameters_slope_chart_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "category_var", "Category (line per group)")),
      column(width = 3, bgc_column_select(id, "time_var", "Time / phase column")),
      column(width = 3, bgc_column_select(id, "value_var", "Value (numeric)")),
      column(width = 3, bgc_column_select(id, "color_var", "Color group (optional)"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 2, sliderInput(NS(id, "line_size"), "Line Width", value = 1, min = 0.2, max = 5, step = 0.1)),
      column(width = 2, sliderInput(NS(id, "point_size"), "Point Size", value = 4, min = 0, max = 12, step = 0.5)),
      column(width = 2, sliderInput(NS(id, "label_size"), "Label Size", value = 14, min = 5, max = 40)),
      column(width = 3,
             prettyRadioButtons(NS(id, "show_labels"),
                                label = "Endpoint Labels",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("no","yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             prettyRadioButtons(NS(id, "discrete_color_choose"),
                                label = "Color palette",
                                choiceNames = c("none","npg","aaas","lancet","jco","nejm"),
                                choiceValues = c("","scale_color_npg","scale_color_aaas","scale_color_lancet","scale_color_jco","scale_color_nejm"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
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
