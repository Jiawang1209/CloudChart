ggplot2_parameters_manhattan_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "chrom_var", "Chromosome column")),
      column(width = 3, bgc_column_select(id, "pos_var", "Position (BP)")),
      column(width = 3, bgc_column_select(id, "pvalue_var", "P-value")),
      column(width = 3, bgc_column_select(id, "snp_var", "SNP / label (optional)"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 3, sliderInput(NS(id, "point_size"), "Point Size", value = 1.2, min = 0.2, max = 5, step = 0.1)),
      column(width = 3, sliderInput(NS(id, "label_size"), "Label Size", value = 12, min = 5, max = 30)),
      column(width = 3, numericInput(NS(id, "sig_threshold"), "Genome-wide threshold", value = 5e-8, min = 0, step = 1e-8)),
      column(width = 3, numericInput(NS(id, "sug_threshold"), "Suggestive threshold", value = 1e-5, min = 0, step = 1e-6))
    ),
    fluidRow(
      align = "center",
      column(width = 4, colourInput(NS(id, "color_a"), "Color A", value = "#1f3b5b")),
      column(width = 4, colourInput(NS(id, "color_b"), "Color B", value = "#e76f51")),
      column(width = 4,
             prettyRadioButtons(NS(id, "highlight_sig"),
                                label = "Highlight significant",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("no","yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 3, textInput(NS(id, "plot_title"), "Set plot title", value = NULL)),
        column(width = 3, textInput(NS(id, "plot_subtitle"), "Set plot subtitle", value = NULL)),
        column(width = 3, textInput(NS(id, "x_axis_Title"), "Set x axis title", value = "Chromosome")),
        column(width = 3, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = "-log10(P)"))
      ),
      tags$hr(),
      prettyRadioButtons(inputId = NS(id, "theme_choose"),
                         label = "Theme Choose:",
                         choiceNames = c("default","theme:bw","theme:classic","theme:clean","theme:GraphPadPrism"),
                         choiceValues = c("theme_grey","theme_bw","theme_classic","theme_clean","theme_prism"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE)
    )
  )
}
