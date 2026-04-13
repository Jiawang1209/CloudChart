ggplot2_parameters_lollipop_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      # Set x Axis Variable
      column(width = 3, textInput(NS(id, "x_axis"), "Set x axis variable", value = NULL)),
      # Set y Axis Variable
      column(width = 3, textInput(NS(id, "y_axis"), "Set y axis variable", value = NULL)),
      # Set color Variable
      column(width = 3, textInput(NS(id, "color_variable"), "Set color variable", value = NULL))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set Segment size
      column(width = 3, sliderInput(NS(id, "border_width"), "Border Width", value = 0.5, min = 0, max = 5, step = 0.25)),
      # Set Segment linetype
      column(width = 3, 
             pickerInput(NS(id, "line_type"),
                         label = "Line Type",
                         choices = c("solid", "dashed",
                                     "twodash", "dotdash",
                                     "longdash","dotted",
                                     "blank"),
                         options = list(style = "btn-primary"))),
      # Set Segment color
      column(width = 3,
             colourInput(NS(id, "line_color"), "Set Line Color", value = "#000000"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set point size
      column(width = 2, sliderInput(NS(id, "point_size"), "Point Size", value = 10, min = 0, max = 40)),
      # Set point alpha
      column(width = 2, sliderInput(NS(id, "point_alpha"), "Point Alpha", value = 1, min = 0, max = 1)),
      # Set point color
      column(width = 2, colourInput(NS(id, "point_color"), "Set point Color", value = "#69b3a2")),
      # Set coord_flip
      column(width = 2, 
             pickerInput(NS(id, "coord_flip"),
                         label = "Plot Coord Flip",
                         choices = c("No", "Yes"),
                         options = list(style = "btn-primary"))
      )
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set  Title
      column(width = 2, textInput(NS(id, "plot_title"), "Set plot title",value = NULL)),
      #Set plot subtitle
      column(width = 2, textInput(NS(id, "plot_subtitle"), "Set plot subtitle",value = NULL)),
      #Set x Axis label
      column(width = 2, textInput(NS(id, "x_axis_Title"), "Set x axis title",value = NULL)),
      #Set y Axis label
      column(width = 2, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = NULL)),
      #Set x limites
      column(width = 2, numericRangeInput(NS(id, "x_limite"), "Set x axis limites", value = c(NULL, NULL))),
      #Set y limites
      column(width = 2, numericRangeInput(NS(id, "y_limite"), "Set y axis limites", value = c(NULL, NULL))),
    ),
    tags$hr(),
    # Set Theme
    prettyRadioButtons(inputId = NS(id, "theme_choose"),
                       label = "Theme Choose:",
                       choiceNames = c("default","theme:bw","theme:classic","theme:clean","theme:GraphPadPrism",
                                       "theme:excel", "theme:stata","theme:economist","theme:GoogleDocs","theme:WallStreetJournal"),
                       choiceValues = c("theme_grey", "theme_bw", "theme_classic","theme_clean", "theme_prism", "theme_excel_new",
                                        "theme_stata", "theme_economist_white","theme_gdocs", "theme_wsj"),
                       icon = icon("check"), #icon = icon("user")
                       animation = "tada",
                       inline = TRUE
    )
  )
}