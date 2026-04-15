ggplot2_parameters_dountplot_UI <- function(id){
  fluidPage(
    # set violin plot
    fluidRow(
      align = "center",
      #Set Size
      column(width = 3, sliderInput(NS(id, "pie_width"), "Pie Width", value = c(1, 4), min = 0, max = 10)),
      column(width = 3, sliderInput(NS(id, "pie_line_width"), "Pie Line Width", value = 0.5, min = 0, max = 5, step = 0.25)),
      column(width = 3, sliderInput(NS(id, "pie_alpha"), "Pie Alpha", value = 1, min = 0, max = 1)),
      column(width = 3, colourInput(NS(id, "pie_border_color"), "Pie Border Color", value = "#000000"))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      #Set Size
      column(width = 3, sliderInput(NS(id, "pie_range"), "Pie Width", value = c(-4, 4), min = -10, max = 10))
    ),
    tags$hr(),
    # set box plot
    fluidRow(
      align = "center",
      # Set box plot
      column(width = 3, 
             prettyRadioButtons(NS(id, "add_label"), 
                                label = "Add Label",
                                choiceNames = c("Yes", "No"),
                                choiceValues = c("Yes", "No"),
                                icon = icon("check"), #icon = icon("user")
                                animation = "tada",
                                inline = TRUE)
      ),
      column(width = 3, sliderInput(NS(id, "lable_position"), "Label Position", value = 2.5, min = -10, max = 10)),
      column(width = 3, sliderInput(NS(id, "lable_size"), "Label Size", value = 6.5, min = 0, max = 10, sep = 0.5)),
      column(width = 3, colourInput(NS(id, "label_color"), "Label Color", value = "#000000")),
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set Add Point
      column(width = 3, 
             prettyRadioButtons(NS(id, "add_percentage"), 
                                label = "Add Percentage",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"), #icon = icon("user")
                                animation = "tada",
                                inline = TRUE)
      ),
      column(width = 3, sliderInput(NS(id, "percentage_position"), "Percentage Position", value = 2.5, min = 0, max = 10)),
      column(width = 3, sliderInput(NS(id, "percentage_size"), "Add Percentage Size", value = 2.5, min = 0, max = 10)),
      column(width = 3, colourInput(NS(id, "add_lable_color"), "Add Percentage Color", value = "#000000"))
    ),

    bgc_advanced_options(
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
                         inline = TRUE
      )
    )
  )
}