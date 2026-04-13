ggplot2_parameters_radar_plot_UI <- function(id){
  fluidPage(
    fluidRow(
      align = "center",
      # Set x Axis Variable
      column(width = 3, textInput(NS(id, "grid.min"), "Set minimum grid value base your data", value = NULL)),
      # Set y Axis Variable
      column(width = 3, textInput(NS(id, "grid.mid"), "Set middle grid value base your data", value = NULL)),
      # Set color Variable
      column(width = 3, textInput(NS(id, "grid.max"), "Set maximum grid value base your data", value = NULL))
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set line width
      column(width = 3, sliderInput(NS(id, "line_width"), "Line Width", value = 1, min = 0, max = 10, step = 0.5)),
      # Set point size
      column(width = 3, sliderInput(NS(id, "point_size"), "Point Width", value = 3, min = 0, max = 10, step = 0.5)),
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set grid label size
      column(width = 3, sliderInput(NS(id, "grid_label_size"), "Grid Label Size", value = 10, min = 0, max = 20)),
      # Set axis label size
      column(width = 3, sliderInput(NS(id, "axis_label_size"), "Axis Label Size", value = 10, min = 0, max = 20)),
    ),
    tags$hr(),
    fluidRow(
      align = "center",
      # Set group color
      column(width = 3, colourInput(NS(id, "group_color"), "Group Color", value = "#df65b0")),
      # Set background color
      column(width = 3, colourInput(NS(id, "background_color"), "Background Color", value = "#999999")),
      # Set gridline mid color
      column(width = 3, colourInput(NS(id, "gridline_mid_color"), "Middle Grid Color", value = "#1d91c0"))
    ),
    tags$hr(),

  )
}