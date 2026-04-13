ggplot2_parameters_forest_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "label_column", "Study / variable label")),
      column(width = 3, bgc_column_select(id, "estimate_column", "Estimate (numeric)")),
      column(width = 3, bgc_column_select(id, "lower_column", "Lower CI (numeric)")),
      column(width = 3, bgc_column_select(id, "upper_column", "Upper CI (numeric)"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "group_column", "Group column (optional)")),
      column(width = 3, numericInput(NS(id, "ref_value"), "Reference Line", value = 0)),
      column(width = 3,
             prettyRadioButtons(NS(id, "log_scale"),
                                label = "X Scale",
                                choiceNames = c("Linear","Log10"),
                                choiceValues = c("linear","log10"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3,
             prettyRadioButtons(NS(id, "show_values"),
                                label = "Show Estimate Text",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      column(width = 2, sliderInput(NS(id, "point_size"), "Point Size", value = 4, min = 0, max = 15, step = 0.25)),
      column(width = 2, sliderInput(NS(id, "whisker_width"), "Whisker Size", value = 0.8, min = 0, max = 5, step = 0.1)),
      column(width = 2, colourInput(NS(id, "point_color"), "Point Color", value = "#2C3E50")),
      column(width = 2, colourInput(NS(id, "ref_color"), "Reference Color", value = "#AA3333")),
      column(width = 2,
             pickerInput(NS(id, "ref_linetype"),
                         label = "Reference Type",
                         choices = c("dashed","solid","twodash","dotdash","longdash","dotted","blank"),
                         options = list(style = "btn-primary"))),
      column(width = 2, sliderInput(NS(id, "label_size"), "Label Size", value = 14, min = 5, max = 40))
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 3, textInput(NS(id, "plot_title"), "Set plot title", value = NULL)),
        column(width = 3, textInput(NS(id, "plot_subtitle"), "Set plot subtitle", value = NULL)),
        column(width = 3, textInput(NS(id, "x_axis_Title"), "Set x axis title", value = "Estimate (95% CI)")),
        column(width = 3, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = NULL))
      ),
      tags$hr(),
      fluidRow(
        align = "center",
        column(width = 6, numericRangeInput(NS(id, "x_limite"), "Set x axis limits", value = c(NA, NA)))
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
