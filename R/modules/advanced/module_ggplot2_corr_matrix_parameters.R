ggplot2_parameters_corr_matrix_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3,
             prettyRadioButtons(NS(id, "cor_method"),
                                label = "Correlation Method",
                                choiceNames = c("Pearson","Spearman","Kendall"),
                                choiceValues = c("pearson","spearman","kendall"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             prettyRadioButtons(NS(id, "matrix_shape"),
                                label = "Matrix Shape",
                                choiceNames = c("Full","Upper","Lower"),
                                choiceValues = c("full","upper","lower"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             prettyRadioButtons(NS(id, "reorder_method"),
                                label = "Reorder",
                                choiceNames = c("Original","Hclust"),
                                choiceValues = c("original","hclust"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             prettyRadioButtons(NS(id, "show_label"),
                                label = "Show Cell Labels",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 12, bgc_multi_column_select(id, "metadata_columns", "Metadata / Group Columns (excluded from the matrix)"))
    ),
    fluidRow(
      align = "center",
      column(width = 3, sliderInput(NS(id, "label_digits"), "Label Digits", value = 2, min = 0, max = 4, step = 1)),
      column(width = 3, sliderInput(NS(id, "label_size"), "Label Size", value = 15, min = 0, max = 50)),
      column(width = 3, colourInput(NS(id, "label_color"), "Label Color", value = "#000000")),
      column(width = 3, colourInput(NS(id, "tile_border"), "Tile Border", value = "#FFFFFF"))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 3, textInput(NS(id, "plot_title"), "Set plot title", value = NULL)),
        column(width = 3, textInput(NS(id, "plot_subtitle"), "Set plot subtitle", value = NULL)),
        column(width = 3, colourInput(NS(id, "low_color"), "Low Color (-1)", value = "#2166AC")),
        column(width = 3, colourInput(NS(id, "high_color"), "High Color (+1)", value = "#B2182B"))
      ),
      tags$hr(),
      fluidRow(
        align = "center",
        column(width = 4, colourInput(NS(id, "mid_color"), "Mid Color (0)", value = "#F7F7F7"))
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
