ggplot2_parameters_pcoa_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      # Set x Axis Variable
      column(width = 2, textInput(NS(id, "x_axis"), "Set x axis variable", value = "Axis.1")),
      # Set y Axis Variable
      column(width = 2, textInput(NS(id, "y_axis"), "Set y axis variable", value = "Axis.2")),
      # Set fill Variable
      column(width = 2, textInput(NS(id, "fill_variable"), "Set fill variable", value = NULL)),
      # Set color Variable
      column(width = 2, textInput(NS(id, "color_variable"), "Set color variable", value = NULL)),
      # # Set shape Variable,
      column(width = 2, textInput(NS(id, "shape_variable"), "Set shape variable", value = NULL)),
      # # Set Shape Variable
      column(width = 2, numericRangeInput(NS(id, "shape_value"), "Set shape value", value = c(NULL, NULL)))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set PCoA Correction Method
      column(width = 3, 
             prettyRadioButtons(NS(id, "pcoa_correlation_method"), 
                                label = "PCoA Correction Method",
                                choiceNames = c("none","lingoes","cailliez"),
                                choiceValues = c("none","lingoes","cailliez"),
                                icon = icon("check"), #icon = icon("user")
                                animation = "tada",
                                inline = TRUE)
      ),
      # Set Point Size
      column(width = 2, sliderInput(NS(id, "point_size"), "Point Size", value = 8, min = 0, max = 20, step = 0.5)),
      # Set Point alpha
      column(width = 2, sliderInput(NS(id, "point_alpha"), "Point Alpha", value = 0.5, min = 0, max = 1, step = 0.1)),
      # Set Add ellipse
      column(width = 2, 
             prettyRadioButtons(NS(id, "add_ellipse"), 
                                label = "Add Ellipse",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"), #icon = icon("user")
                                animation = "tada",
                                inline = TRUE)
      ),
      # Set ellipse size 
      column(width = 3, sliderInput(NS(id, "ellipse_size"), "Ellipse Size", value = 1, min = 0, max = 20, step = 0.5))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set Plot Title
      column(width = 2, textInput(NS(id, "plot_title"), "Set plot title",value = NULL)),
      # Set plot subtitle
      column(width = 2, textInput(NS(id, "plot_subtitle"), "Set plot subtitle",value = NULL)),
      # #Set x Axis label
      # column(width = 2, textInput(NS(id, "x_axis_Title"), "Set x axis title",value = NULL)),
      # #Set y Axis label
      # column(width = 2, textInput(NS(id, "y_axis_Title"), "Set y axis title", value = NULL)),
      # Set x limites
      column(width = 2, numericRangeInput(NS(id, "x_limite"), "Set x axis limites", value = c(NULL, NULL))),
      # Set y limites
      column(width = 2, numericRangeInput(NS(id, "y_limite"), "Set y axis limites", value = c(NULL, NULL))),
      # Set label Size
      column(width = 4, sliderInput(NS(id, "label_size"), "Lable Size", value = 15, min = 0, max = 50)),
    ),
    tags$hr(),
    # Set Theme
    prettyRadioButtons(inputId = NS(id, "theme_choose"),
                       label = "Theme Choose:",
                       choiceNames = c("default","theme:bw","theme:classic","theme:clean","theme:GraphPadPrism",
                                       "theme:excel", "theme:stata","theme:economist","theme:GoogleDocs","theme:WallStreetJournal"),
                       choiceValues = c("theme_grey", "theme_bw", "theme_classic","theme_clean", "theme_prism", "theme_excel_new",
                                        "theme_stata", "theme_economist_white","theme_gdocs", "theme_wsj"),
                       icon = icon("check"), # icon = icon("user")
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
    prettyRadioButtons(inputId = NS(id, "discrete_color_choose"),
                       label = "Discrete color Palettes:",
                       choiceNames = c("default","NPG","AAAS","NEJM","Lancet","JAMA","JCO","UCSCGB","D3","LocusZoom","IGV","UChicago"),
                       choiceValues = c("", "scale_color_npg","scale_color_aaas","scale_color_nejm","scale_color_lancet",
                                        "scale_color_jama","scale_color_jco","scale_color_ucscgb","scale_color_d3",
                                        "scale_color_locuszoom","scale_color_igv","scale_color_uchicago"),
                       icon = icon("check"),
                       animation = "tada",
                       inline = TRUE)
  )
}