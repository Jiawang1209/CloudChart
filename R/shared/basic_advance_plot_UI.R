basic_advance_plot_UI <- function(tabName, inputid, title, fun){
  tabItem(
    tabName = tabName,
    header_tabItem(title = title),
    fluidPage(
      bs4TabCard(
        width = 12,
        type = "pills",
        
        tabPanel(
          title = "Example Data",
          fluidPage(
            fluidRow(
              column(
                width = 12,
                align = "center",
                show_example_data_UI(id = inputid)
              )
            )
          )
        ),
        
        tabPanel(
          title = "Data & Parameters",
          fluidPage(
            fluidRow(
              column(
                width = 3,
                file_upload_UI(id = inputid)
              ),
              column(
                width = 9,
                file_upload_show_UI(id = inputid)
              )
            )
          ),
          tags$hr(),
          fluidPage(
            get(fun)(inputid)
          )
        ),
        
        tabPanel(
          title = "Plot",
          fluidPage(
            ggplot2_plot_download_UI(id = inputid)
          )
        ),
        
        tabPanel(
          title = "Interactive",
          fluidPage(
            p("Generate the static plot first, then click the button below only when you need the interactive view."),
            ggplot2_plotly_UI(id = inputid)
          )
        )
      )
    )
  )
}
  
  
