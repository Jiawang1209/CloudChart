# Legacy UI snapshot.
# Active UI shell: R/basic_advance_plot_UI.R

basic_advance_plot_UI_2 <- function(tabName, inputid, title){
  tabItem(
    tabName = tabName,
    header_tabItem(title = title),
    tags$hr(),
    fluidPage(
      bs4TabCard(
        width = 12,
        type = "pills",
        
        # Demo Input DataFrame
        tabPanel(
          title = "Demo Input DataFrame",
          h3("Demo DataFrame"),
          tags$hr(),
          # h4(paste0(title, " DataFrame: Data Table")),
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
        
        # Input Your DataFrame
        tabPanel(
          title = "Input Your DataFrame",
          tags$hr(),
          fluidPage(
            fluidRow(
              column(
                width = 4,
                align = "center",
                file_upload_UI(id = inputid)
              ),
              column(
                width = 8,
                align = "center",
                file_upload_show_UI(id = inputid)
              )
            )
          )
        ),
        
        # Set Parameters
        tabPanel(
          title = "Set Parameters",
          tags$hr(),
          fluidPage(
            fluidRow(
              width = 12,
              # align = "center",
              ggplot2_parameters_dotplot_UI(id = inputid)
            )
          )
        ),
        
        # Visualise Results
        tabPanel(
          title = "Visualise Results",
          tags$hr(),
          fluidPage(
            fluidRow(
              width = 12,
              align = "center",
              ggplot2_plot_download_UI(id = inputid)
            )
          )
        ),
        
        tabPanel(
          title = "Interactive Graphics",
          tags$hr(),
          fluidPage(
            fluidRow(
              width = 12,
              align = "center",
              ggplot2_plotly_UI(id = inputid)
            )
          )
        )
      )
    )
  )
}
