ggplot2_parameters_waffle_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 4, bgc_column_select(id, "category_var", "Category column")),
      column(width = 4, sliderInput(NS(id, "grid_rows"), "Rows", value = 10, min = 4, max = 25)),
      column(width = 4, sliderInput(NS(id, "grid_cols"), "Cols", value = 10, min = 4, max = 25))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 3, sliderInput(NS(id, "tile_pad"), "Tile gap", value = 0.05, min = 0, max = 0.4, step = 0.05)),
      column(width = 3, sliderInput(NS(id, "label_size"), "Label size", value = 14, min = 5, max = 40)),
      column(width = 6,
             prettyRadioButtons(NS(id, "discrete_fill_choose"),
                                label = "Fill palette",
                                choiceNames = c("none","npg","aaas","lancet","jco","nejm"),
                                choiceValues = c("","scale_fill_npg","scale_fill_aaas","scale_fill_lancet","scale_fill_jco","scale_fill_nejm"),
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
