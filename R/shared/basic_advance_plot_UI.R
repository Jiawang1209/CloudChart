basic_advance_plot_body <- function(inputid, fun){
  bgc_tabcard_shell(
    inputid, fun,
    list(
      tabPanel(
        title = "Plot",
        fluidPage(ggplot2_plot_download_UI(id = inputid))
      ),
      tabPanel(
        title = "Interactive",
        fluidPage(
          p("Generate the static plot first, then click the button below only when you need the interactive view."),
          ggplot2_plotly_UI(id = inputid)
        )
      ),
      tabPanel(
        title = "R Code",
        fluidPage(
          p("Best-effort ggplot2 reproduction of the plot you just built. Click Plot first, then copy this snippet to rerun the same visual outside CloudChart."),
          verbatimTextOutput(
            outputId = NS(inputid, "plotCode"),
            placeholder = TRUE
          )
        )
      )
    )
  )
}

basic_advance_plot_UI <- function(tabName, inputid, title, fun){
  tabItem(
    tabName = tabName,
    header_tabItem(title = title),
    basic_advance_plot_body(inputid, fun)
  )
}
  
  
