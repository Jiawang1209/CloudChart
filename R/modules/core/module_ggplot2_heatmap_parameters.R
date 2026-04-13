ggplot2_parameters_heatmap_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      column(width = 3, bgc_column_select(id, "x_axis", "Set x axis variable")),
      column(width = 3, bgc_column_select(id, "y_axis", "Set y axis variable")),
      column(width = 3, bgc_column_select(id, "fill_variable", "Set fill (numeric)")),
      column(width = 3,
             prettyRadioButtons(NS(id, "aggregate_fun"),
                                label = "Aggregate",
                                choiceNames = c("Mean","Median","Sum","Max","Min"),
                                choiceValues = c("mean","median","sum","max","min"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE))
    ),
    fluidRow(
      align = "center",
      column(width = 3,
             prettyRadioButtons(NS(id, "show_label"),
                                label = "Show Cell Labels",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"),
                                animation = "tada",
                                inline = TRUE)),
      column(width = 3, sliderInput(NS(id, "label_digits"), "Label Digits", value = 1, min = 0, max = 4, step = 1)),
      column(width = 3, sliderInput(NS(id, "label_size"), "Label Size", value = 15, min = 0, max = 50)),
      column(width = 3, colourInput(NS(id, "label_color"), "Label Color", value = "#FFFFFF"))
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
      fluidRow(
        align = "center",
        column(width = 3, colourInput(NS(id, "low_color"), "Low Color", value = "#FFF7BC")),
        column(width = 3, colourInput(NS(id, "mid_color"), "Mid Color", value = "#FE9929")),
        column(width = 3, colourInput(NS(id, "high_color"), "High Color", value = "#993404")),
        column(width = 3,
               prettyRadioButtons(NS(id, "use_midpoint"),
                                  label = "Use Mid Color",
                                  choiceNames = c("No","Yes"),
                                  choiceValues = c("No","Yes"),
                                  icon = icon("check"),
                                  animation = "tada",
                                  inline = TRUE))
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
