ggplot2_parameters_smooth_line_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      # Set x Axis Variable
      column(width = 2, textInput(NS(id, "x_axis"), "Set x axis variable", value = NULL)),
      # Set y Axis Variable
      column(width = 2, textInput(NS(id, "y_axis"), "Set y axis variable", value = NULL)),
      column(width = 4, sliderInput(NS(id, "spline_shape"), "Spline Shape", value = -0.25, min = -1, max = 1, step = 0.05))
      # # Set barplot position
      # column(width = 2,
      #        pickerInput(NS(id, "position"), 
      #                    label = "Bar Position",
      #                    choices = c("dodge", "stack", "fill"),
      #                    options = list(style = "btn-primary"))
      # ),
      # column(width = 2,
      #        pickerInput(NS(id, "linetype"),
      #                    label = "Bar Border Type",
      #                    choices = c("solid", "dashed",
      #                                "twodash", "dotdash",
      #                                "longdash","dotted",
      #                                "blank"),
      #                    options = list(style = "btn-primary")))
      # # Set shape Variable,
      # column(width = 2, textInput(NS(id, "shape_variable"), "Set shape variable", value = NULL)),
      # # Set Shape Variable
      # column(width = 2, numericRangeInput(NS(id, "shape_value"), "Set shape value", value = c(NULL, NULL)))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set group Variable
      column(width = 2, textInput(NS(id, "group_variable"), "Set group variable", value = NULL)),
      # Set color Variable
      column(width = 2, textInput(NS(id, "color_variable"), "Set color variable", value = NULL)),
      # Set linetype Variable
      column(width = 2, textInput(NS(id, "linetype_variable"), "Set linetype variable", value = NULL)),
      # Set fill Variable Class
      column(width = 2, 
             prettyRadioButtons(NS(id, "add_point"), 
                                label = "Add Point",
                                choiceNames = c("Yes","No"),
                                choiceValues = c("Yes","No"),
                                icon = icon("check"), #icon = icon("user")
                                animation = "tada",
                                inline = TRUE)
      ),
      column(width = 4, sliderInput(NS(id, "point_size"), "Point Size", value = 5, min = 0, max = 20)),
    ),
    
    tags$hr(),
    fluidRow(
      align = "center",
      #Set Size
      column(width = 2, sliderInput(NS(id, "border_width"), "Border Width", value = 0.5, min = 0, max = 2, step = 0.25)),
      column(width = 2, sliderInput(NS(id, "point_width"), "Point Width", value = 0.5, min = 0, max = 2, step = 0.25)),
      column(width = 2, sliderInput(NS(id, "label_size"), "Lable Size", value = 15, min = 0, max = 50)),
      column(width = 2, sliderInput(NS(id, "alpha"), "Border Alpha", value = 0.8, min = 0, max = 1)),
      column(width = 2, colourInput(NS(id, "border_color"), "Set Border Color", value = "#000000")),
      column(width = 2, colourInput(NS(id, "fill_color"), "Set Fill Color", value = "#969696"))
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
      ),
      prettyRadioButtons(inputId = NS(id, "continuous_fill_choose"),
                         label = "Continuous fill Palettes:",
                         choiceNames = c("default","Red","Pink","Purple","Indigo","Blue","Cyan","Teal",
                                         "Green","Lime","Yellow","Amber","Orange","Brown","Grey"),
                         choiceValues = c("","red","pink","purple","indigo","blue","cyan","teal",
                                          "green","lime","yellow","amber","orange","brown","grey"),
                         icon = icon("check"),
                         animation = "tada",
                         inline = TRUE
      )
    )
  )
}