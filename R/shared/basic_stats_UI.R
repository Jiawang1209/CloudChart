basic_stats_UI <- function(tabName, inputid, title, fun){
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
          title = "Results",
          fluidPage(
            stats_result_UI(id = inputid)
          )
        )
      )
    )
  )
}

stats_result_UI <- function(id){
  tagList(
    fluidRow(
      column(
        width = 12,
        align = "center",
        actionBttn(
          inputId = NS(id, "run_analysis"),
          label = "Run Analysis",
          color = "primary",
          style = "bordered",
          icon = icon("play")
        )
      )
    ),
    tags$hr(),
    fluidRow(
      column(
        width = 12,
        tags$h4("Summary"),
        verbatimTextOutput(NS(id, "stats_summary"))
      )
    ),
    tags$hr(),
    fluidRow(
      column(
        width = 12,
        tags$h4("Results Table"),
        tableOutput(NS(id, "stats_table"))
      )
    ),
    tags$hr(),
    fluidRow(
      column(
        width = 12,
        align = "center",
        downloadButton(NS(id, "download_results"), "Download CSV")
      )
    )
  )
}

bind_stats_outputs <- function(output, input, print_fn, table_fn, filename_prefix){
  output$stats_summary <- renderPrint({
    validate(need(input$run_analysis > 0, "Click 'Run Analysis' to compute results."))
    print_fn()
  })

  output$stats_table <- renderTable({
    validate(need(input$run_analysis > 0, "Click 'Run Analysis' to compute results."))
    table_fn()
  }, digits = 4)

  output$download_results <- downloadHandler(
    filename = function(){
      paste0(filename_prefix, "_", Sys.Date(), ".csv")
    },
    content = function(file){
      write.csv(table_fn(), file, row.names = FALSE)
    }
  )
}
