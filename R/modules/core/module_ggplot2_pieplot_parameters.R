ggplot2_parameters_pieplot_UI <- function(id){
  fluidPage(
    tags$hr(),
    # set violin plot
    fluidRow(
      align = "center",
      #Set Size
      column(width = 3, sliderInput(NS(id, "pie_width"), "Pie Width", value = 2, min = 0, max = 5, step = 0.25)),
      column(width = 3, sliderInput(NS(id, "pie_line_width"), "Pie Line Width", value = 1, min = 0, max = 5, step = 0.25)),
      column(width = 3, sliderInput(NS(id, "pie_alpha"), "Pie Alpha", value = 1, min = 0, max = 1)),
      column(width = 3, colourInput(NS(id, "pie_border_color"), "Pie Border Color", value = "#FFFFFF"))
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
      column(width = 3, sliderInput(NS(id, "lable_position"), "Label Position", value = 0.75, min = 0.1, max = 5)),
      column(width = 3, sliderInput(NS(id, "lable_size"), "Label Size", value = 5, min = 0, max = 10)),
      column(width = 3, colourInput(NS(id, "label_color"), "Label Color", value = "#000000")),
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set Add Point
      column(width = 3, 
             prettyRadioButtons(NS(id, "add_bar_label"), 
                                label = "Add Bar and Label",
                                choiceNames = c("No","Yes"),
                                choiceValues = c("No","Yes"),
                                icon = icon("check"), #icon = icon("user")
                                animation = "tada",
                                inline = TRUE)
      ),
      column(width = 3, sliderInput(NS(id, "add_lable_position"), "Add Label Position", value = 1, min = 0, max = 10)),
      column(width = 3, sliderInput(NS(id, "add_lable_size"), "Add Label Size", value = 5, min = 0, max = 10)),
      # column(width = 2, sliderInput(NS(id, "boxplot_alpha"), "Boxplot Alpha", value = 1, min = 0, max = 1)),
      column(width = 3, colourInput(NS(id, "add_lable_color"), "Add Label Bar Color", value = "#000000")),
      # column(width = 2, colourInput(NS(id, "bar_lable_color"), "Label Color", value = "#000000"))
      # column(width = 2, colourInput(NS(id, "boxplot_fill_color"), "Set Boxplot Fill Color", value = "#969696"))
    ),
    fluidRow(
      align = "center",
      # column(width = 2, sliderInput(NS(id, "add_bar_position"), "Add Bar Position", value = 0.2, min = 0.1, max = 1)),
      column(width = 3, sliderInput(NS(id, "add_bar_size"), "Add Bar Size", value = 1, min = 0, max = 10)),
      # column(width = 2, sliderInput(NS(id, "boxplot_alpha"), "Boxplot Alpha", value = 1, min = 0, max = 1)),
      column(width = 3, sliderInput(NS(id, "add_bar_angle"), "Add Bar Angle", value = 20, min = 0, max = 180, step = 20)),
      column(width = 3, sliderInput(NS(id, "add_bar_x"), "Add Bar xaxis", value = 0.25, min = 0, max = 5)),
      column(width = 3, sliderInput(NS(id, "add_bar_y"), "Add Bar yaxis", value = 0, min = 0, max = 5)),
      # column(width = 2, colourInput(NS(id, "add_bar_color"), "Add Bar Color", value = "#000000"))
    ),
    tags$hr(),
    # Set Theme
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
}