ggplot2_parameters_nmds_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_multi_column_select(id, "metadata_columns", "Metadata columns (excluded)")),
      column(width = 4, bgc_column_select(id, "color_var", "Color by (optional metadata)")),
      column(width = 4,
             prettyRadioButtons(NS(id, "distance"),
                                label = "Distance",
                                choiceNames = c("bray","euclidean","manhattan","jaccard"),
                                choiceValues = c("bray","euclidean","manhattan","jaccard"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    fluidRow(
      align = "center",
      column(width = 3, sliderInput(NS(id, "k_dim"), "Dimensions (k)", value = 2, min = 2, max = 4)),
      column(width = 3, sliderInput(NS(id, "trymax"), "Try max", value = 50, min = 10, max = 200, step = 10)),
      column(width = 3, sliderInput(NS(id, "point_size"), "Point Size", value = 4, min = 1, max = 12)),
      column(width = 3, sliderInput(NS(id, "label_size"), "Label Size", value = 14, min = 5, max = 40))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 2, textInput(NS(id, "plot_title"), "Set plot title", value = NULL)),
        column(width = 2, textInput(NS(id, "plot_subtitle"), "Set plot subtitle", value = NULL)),
        column(width = 2, textInput(NS(id, "x_axis_Title"), "Set x axis title", value = "NMDS1")),
        column(width = 2, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = "NMDS2")),
        column(width = 2, numericRangeInput(NS(id, "x_limite"), "Set x axis limits", value = c(NA, NA))),
        column(width = 2, numericRangeInput(NS(id, "y_limite"), "Set y axis limits", value = c(NA, NA)))
      ),
      tags$hr(),
      prettyRadioButtons(NS(id, "discrete_color_choose"),
                         label = "Color palette",
                         choiceNames = c("none","npg","aaas","lancet","jco","nejm"),
                         choiceValues = c("","scale_color_npg","scale_color_aaas","scale_color_lancet","scale_color_jco","scale_color_nejm"),
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
