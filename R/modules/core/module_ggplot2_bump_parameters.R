ggplot2_parameters_bump_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "x_axis", "Time / x variable")),
      column(width = 3, bgc_column_select(id, "y_axis", "Value / rank variable (numeric)")),
      column(width = 3, bgc_column_select(id, "group_column", "Group / line variable")),
      column(width = 3,
             prettyRadioButtons(NS(id, "value_mode"),
                                label = "Y Mode",
                                choiceNames = c("Rank","Raw Value"),
                                choiceValues = c("rank","raw"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 2, sliderInput(NS(id, "line_size"), "Line Size", value = 1, min = 0, max = 5, step = 0.1)),
      column(width = 2, sliderInput(NS(id, "point_size"), "Point Size", value = 4, min = 0, max = 15, step = 0.25)),
      column(width = 2, sliderInput(NS(id, "smooth"), "Smooth", value = 8, min = 1, max = 20, step = 1)),
      column(width = 2, sliderInput(NS(id, "line_alpha"), "Line Alpha", value = 1, min = 0, max = 1, step = 0.05)),
      column(width = 2,
             prettyRadioButtons(NS(id, "show_labels"),
                                label = "Show Endpoint Labels",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 2,
             prettyRadioButtons(NS(id, "reverse_y"),
                                label = "Reverse Y (rank 1 top)",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
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
      fluidRow(
        align = "center",
        column(width = 6, sliderInput(NS(id, "label_size"), "Label Size", value = 14, min = 5, max = 40))
      ),
      tags$hr(),
      prettyRadioButtons(inputId = NS(id, "discrete_color_choose"),
                         label = "Discrete color Palettes:",
                         choiceNames = c("default","NPG","AAAS","NEJM","Lancet","JAMA","JCO","UCSCGB","D3","LocusZoom","IGV","UChicago"),
                         choiceValues = c("", "scale_color_npg","scale_color_aaas","scale_color_nejm","scale_color_lancet",
                                          "scale_color_jama","scale_color_jco","scale_color_ucscgb","scale_color_d3",
                                          "scale_color_locuszoom","scale_color_igv","scale_color_uchicago"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE),
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
