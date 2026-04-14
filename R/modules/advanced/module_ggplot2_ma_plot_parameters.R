ggplot2_parameters_ma_plot_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "mean_var", "Mean expression / A")),
      column(width = 3, bgc_column_select(id, "logfc_var", "log2 Fold Change / M")),
      column(width = 3, bgc_column_select(id, "padj_var", "Adjusted p-value (optional)")),
      column(width = 3, bgc_column_select(id, "label_var", "Label column (optional)"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 3, sliderInput(NS(id, "point_size"), "Point Size", value = 1.4, min = 0.2, max = 6, step = 0.1)),
      column(width = 3, sliderInput(NS(id, "label_size"), "Label Size", value = 12, min = 5, max = 30)),
      column(width = 3, numericInput(NS(id, "padj_cut"), "Significance cutoff", value = 0.05, min = 0, max = 1, step = 0.01)),
      column(width = 3, numericInput(NS(id, "lfc_cut"), "|log2FC| cutoff", value = 1, min = 0, step = 0.1))
    ),
    fluidRow(
      align = "center",
      column(width = 3, colourInput(NS(id, "up_color"), "Up color", value = "#e63946")),
      column(width = 3, colourInput(NS(id, "down_color"), "Down color", value = "#1d3557")),
      column(width = 3, colourInput(NS(id, "ns_color"), "NS color", value = "#9aa0a6")),
      column(width = 3,
             prettyRadioButtons(NS(id, "log_x"),
                                label = "log10(mean) X axis",
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
        column(width = 3, textInput(NS(id, "x_axis_Title"), "Set x axis title", value = "Mean expression")),
        column(width = 3, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = "log2 Fold Change"))
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
