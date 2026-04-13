ggplot2_plotly_UI <- function(id){
  fluidPage(
    fluidRow(
      column(
        width = 12,
        align = "center",
        actionBttn(
          inputId = NS(id, "build_interactive_plot"),
          label = "Build Interactive Plot",
          color = "primary",
          style = "bordered"
        )
      )
    ),
    tags$br(),
    fluidRow(
      column(
        width = 12,
        align = "center",
        plotly::plotlyOutput(outputId = NS(id, "interactive_plot"),
                     height = 560,
                     width = "100%")
      )
    )
  )
}
