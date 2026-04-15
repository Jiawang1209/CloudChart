ggplot2_parameters_density_plot_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      # Set x Axis Variable
      column(width = 3, textInput(NS(id, "x_axis"), "Set x axis variable", value = NULL)),
      # Set fill Variable
      column(width = 3, textInput(NS(id, "fill_variable"), "Set fill variable", value = NULL)),
      # Set bar Position
      column(width = 3, 
             pickerInput(
               NS(id, "position"),
               label = "Density Position",
               choices = c("dodge", "fill", "stack"),
               options = list(style = "btn-primary")
             )
      ),
      # Set alpha
      column(width = 3, sliderInput(NS(id, "alpha"), "Density Alpha", value = 0.8, min = 0, max = 1)),
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set line width
      column(width = 3, sliderInput(NS(id, "line_width"), "Line Width", value = 0.75, min = 0, max = 2, step = 0.25)),
      # Set line type
      column(width = 3, 
             pickerInput(NS(id, "line_type"),
                         label = "Line Type",
                         choices = c("solid", "dashed",
                                     "twodash", "dotdash",
                                     "longdash","dotted",
                                     "blank"),
                         options = list(style = "btn-primary"))
             ),
      # Set plot label size
      column(width = 2, sliderInput(NS(id, "label_size"), "Lable Size", value = 15, min = 0, max = 50)),
      # Set line color
      column(width = 2, colourInput(NS(id, "border_color"), "Set Border Color", value = "#000000")),
      # Set facet 
      column(width = 2, 
             pickerInput(NS(id, "facet_wrap"),
                         label = "Plot Facet",
                         choices = c("No", "Yes"),
                         options = list(style = "btn-primary"))
      )
    ),
    bgc_advanced_options(
      fluidRow(
        align = "center",
        column(width = 2, textInput(NS(id, "plot_title"), "Set plot title",value = NULL)),
        column(width = 2, textInput(NS(id, "plot_subtitle"), "Set plot subtitle",value = NULL)),
        column(width = 2, textInput(NS(id, "x_axis_Title"), "Set x axis title",value = NULL)),
        column(width = 2, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = NULL)),
        column(width = 2, numericRangeInput(NS(id, "x_limite"), "Set x axis limites", value = c(NA, NA))),
        column(width = 2, numericRangeInput(NS(id, "y_limite"), "Set y axis limites", value = c(NA, NA)))
      ),
      tags$hr(),
      prettyRadioButtons(inputId = NS(id, "theme_choose"),
                         label = "Theme Choose:",
                         choiceNames = c("default","theme:bw","theme:classic","theme:clean","theme:GraphPadPrism",
                                         "theme:excel", "theme:stata","theme:economist","theme:GoogleDocs","theme:WallStreetJournal"),
                         choiceValues = c("theme_grey", "theme_bw", "theme_classic","theme_clean", "theme_prism", "theme_excel_new",
                                          "theme_stata", "theme_economist_white","theme_gdocs", "theme_wsj"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE
      ),
      prettyRadioButtons(inputId = NS(id, "discrete_fill_choose"),
                         label = "Discrete fill Palettes:",
                         choiceNames = c("default","NPG","AAAS","NEJM","Lancet","JAMA","JCO","UCSCGB","D3","LocusZoom","IGV","UChicago"),
                         choiceValues = c("", "scale_fill_npg","scale_fill_aaas","scale_fill_nejm","scale_fill_lancet",
                                          "scale_fill_jama","scale_fill_jco","scale_fill_ucscgb","scale_fill_d3",
                                          "scale_fill_locuszoom","scale_fill_igv","scale_fill_uchicago"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE
      )
    )
  )
}