ggplot2_parameters_waterfall_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "x_axis", "Category variable (x)")),
      column(width = 3, bgc_column_select(id, "y_axis", "Value variable (y)")),
      column(width = 3,
             prettyRadioButtons(NS(id, "show_total"),
                                label = "Append Total Bar",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             prettyRadioButtons(NS(id, "show_labels"),
                                label = "Show Value Labels",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 2, colourInput(NS(id, "pos_color"), "Positive Fill", value = "#2E8B57")),
      column(width = 2, colourInput(NS(id, "neg_color"), "Negative Fill", value = "#B22222")),
      column(width = 2, colourInput(NS(id, "total_color"), "Total Fill", value = "#4A6FA5")),
      column(width = 2, colourInput(NS(id, "connector_color"), "Connector", value = "#808080")),
      column(width = 2, sliderInput(NS(id, "bar_width"), "Bar Width", value = 0.6, min = 0.1, max = 1.0, step = 0.05)),
      column(width = 2, sliderInput(NS(id, "bar_alpha"), "Bar Alpha", value = 0.9, min = 0, max = 1, step = 0.05))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 3,
             pickerInput(NS(id, "connector_linetype"),
                         label = "Connector Line Type",
                         choices = c("dashed","solid","twodash","dotdash","longdash","dotted","blank"),
                         options = list(style = "btn-primary"))),
      column(width = 3, sliderInput(NS(id, "connector_width"), "Connector Width", value = 0.5, min = 0, max = 3, step = 0.1)),
      column(width = 3, sliderInput(NS(id, "label_size"), "Label Size", value = 15, min = 5, max = 40)),
      column(width = 3, textInput(NS(id, "total_label"), "Total Bar Label", value = "Total"))
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
