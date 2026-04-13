ggplot2_parameters_sankey_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 12, bgc_multi_column_select(id, "axis_columns", "Categorical axes (2 or more columns, left → right)"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "weight_variable", "Weight variable (numeric, optional)")),
      column(width = 3, bgc_column_select(id, "fill_variable", "Fill by column (optional)")),
      column(width = 3,
             prettyRadioButtons(NS(id, "show_stratum_label"),
                                label = "Show Stratum Labels",
                                choiceNames = c("Yes","No"),
                                choiceValues = c("Yes","No"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             prettyRadioButtons(NS(id, "curve_type"),
                                label = "Alluvium Curve",
                                choiceNames = c("x-spline","linear","cubic"),
                                choiceValues = c("xspline","linear","cubic"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 2, sliderInput(NS(id, "alluvium_alpha"), "Alluvium Alpha", value = 0.7, min = 0, max = 1, step = 0.05)),
      column(width = 2, sliderInput(NS(id, "stratum_alpha"), "Stratum Alpha", value = 1, min = 0, max = 1, step = 0.05)),
      column(width = 2, colourInput(NS(id, "stratum_fill"), "Stratum Fill", value = "#EEEEEE")),
      column(width = 2, colourInput(NS(id, "stratum_border"), "Stratum Border", value = "#404040")),
      column(width = 2, sliderInput(NS(id, "stratum_width"), "Stratum Width", value = 0.25, min = 0.05, max = 0.5, step = 0.05)),
      column(width = 2, sliderInput(NS(id, "label_size"), "Label Size", value = 15, min = 5, max = 40))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 3, textInput(NS(id, "plot_title"), "Set plot title", value = NULL)),
        column(width = 3, textInput(NS(id, "plot_subtitle"), "Set plot subtitle", value = NULL)),
        column(width = 3, textInput(NS(id, "x_axis_Title"), "Set x axis title", value = NULL)),
        column(width = 3, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = NULL))
      ),
      tags$hr(),
      prettyRadioButtons(inputId = NS(id, "discrete_fill_choose"),
                         label = "Discrete fill Palettes:",
                         choiceNames = c("default","NPG","AAAS","NEJM","Lancet","JAMA","JCO","UCSCGB","D3","LocusZoom","IGV","UChicago"),
                         choiceValues = c("", "scale_fill_npg","scale_fill_aaas","scale_fill_nejm","scale_fill_lancet",
                                          "scale_fill_jama","scale_fill_jco","scale_fill_ucscgb","scale_fill_d3",
                                          "scale_fill_locuszoom","scale_fill_igv","scale_fill_uchicago"),
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
