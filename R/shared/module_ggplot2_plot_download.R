ggplot2_plot_download_UI <- function(id){
  fluidPage(
    fluidRow(
      column(
        width = 3,
        align = "center",
        actionBttn(
          inputId = NS(id, "Plot"),
          label = "Plot!",
          color = "primary",
          style = "bordered"
        )
      ),
      column(
        width = 3,
        align = "center",
        downloadBttn(
          outputId = NS(id, "Download"),
          label = "Download!",
          color = "primary",
          style = "bordered"
        )
      ),
      column(
        width = 2,
        align = "center",
        numericInputIcon(
          inputId = NS(id, "Width"),
          label = NULL,
          value = 10,
          icon = list("Width")
        )
      ),
      column(
        width = 2,
        align = "center",
        numericInputIcon(
          inputId = NS(id, "Height"),
          label = NULL,
          value = 8,
          icon = list("Height")
        )
      )
    ),
    fluidRow(
      column(
        width = 12,
        align = "center",
        plotOutput(
          outputId = NS(id, "plotOutput"),
          height = 560,
          width = "100%"
        )
      )
    )
  )
}
