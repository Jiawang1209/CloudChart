ggplot2_parameters_parcoord_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 12, bgc_multi_column_select(id, "axis_columns", "Numeric axis columns (2 or more)"))
    ),
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "group_column", "Group column (color by)")),
      column(width = 4,
             pickerInput(NS(id, "scale_method"),
                         label = "Scale Method",
                         choices = c("std","uniminmax","globalminmax","center","centerObs","robust"),
                         selected = "std",
                         options = list(style = "btn-primary"))),
      column(width = 4,
             prettyRadioButtons(NS(id, "show_boxplot"),
                                label = "Overlay Boxplot",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 2, sliderInput(NS(id, "line_alpha"), "Line Alpha", value = 0.5, min = 0, max = 1, step = 0.05)),
      column(width = 2, sliderInput(NS(id, "line_width"), "Line Width", value = 0.6, min = 0, max = 3, step = 0.1)),
      column(width = 2,
             prettyRadioButtons(NS(id, "show_points"),
                                label = "Show Points",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 2, sliderInput(NS(id, "point_size"), "Point Size", value = 1.5, min = 0, max = 10, step = 0.25)),
      column(width = 2, sliderInput(NS(id, "label_size"), "Label Size", value = 14, min = 5, max = 40)),
      column(width = 2,
             prettyRadioButtons(NS(id, "axis_order"),
                                label = "Axis Order",
                                choiceNames = c("Given","By Variance","Anova"),
                                choiceValues = c("given","allClass","anyClass"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
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
