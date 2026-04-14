ggplot2_plot_download_UI <- function(id){
  fluidPage(
    fluidRow(
      column(
        width = 2,
        align = "center",
        actionBttn(
          inputId = NS(id, "Plot"),
          label = "Plot!",
          color = "primary",
          style = "bordered"
        )
      ),
      column(
        width = 2,
        align = "center",
        shinyWidgets::radioGroupButtons(
          inputId = NS(id, "Format"),
          label = NULL,
          choices = c("PDF", "PNG", "SVG"),
          selected = "PDF",
          size = "xs"
        )
      ),
      column(
        width = 2,
        align = "center",
        downloadBttn(
          outputId = NS(id, "Download"),
          label = "Plot",
          color = "primary",
          style = "bordered",
          size = "sm"
        )
      ),
      column(
        width = 2,
        align = "center",
        downloadBttn(
          outputId = NS(id, "DownloadParams"),
          label = "Params",
          color = "default",
          style = "bordered",
          size = "sm"
        )
      ),
      column(
        width = 2,
        align = "center",
        downloadBttn(
          outputId = NS(id, "DownloadData"),
          label = "Data",
          color = "default",
          style = "bordered",
          size = "sm"
        )
      ),
      column(
        width = 1,
        align = "center",
        numericInputIcon(
          inputId = NS(id, "Width"),
          label = NULL,
          value = 10,
          icon = list("W")
        )
      ),
      column(
        width = 1,
        align = "center",
        numericInputIcon(
          inputId = NS(id, "Height"),
          label = NULL,
          value = 8,
          icon = list("H")
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
