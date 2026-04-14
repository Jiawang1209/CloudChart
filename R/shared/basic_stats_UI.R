basic_stats_body <- function(inputid, fun){
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
}

basic_stats_UI <- function(tabName, inputid, title, fun){
  tabItem(
    tabName = tabName,
    header_tabItem(title = title),
    basic_stats_body(inputid, fun)
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
        DT::DTOutput(NS(id, "stats_table"))
      )
    ),
    tags$hr(),
    fluidRow(
      column(
        width = 12,
        tags$h4("Plot"),
        plotOutput(NS(id, "stats_plot"), height = "440px")
      )
    ),
    tags$hr(),
    fluidRow(
      column(
        width = 6,
        align = "center",
        downloadButton(NS(id, "download_results"), "Download CSV")
      ),
      column(
        width = 6,
        align = "center",
        downloadButton(NS(id, "download_plot"), "Download Plot (PDF)")
      )
    )
  )
}

bind_stats_outputs <- function(output, input, print_fn, table_fn, filename_prefix, plot_fn = NULL){
  output$stats_summary <- renderPrint({
    validate(need(input$run_analysis > 0, "Click 'Run Analysis' to compute results."))
    print_fn()
  })

  output$stats_table <- DT::renderDT(
    {
      validate(need(input$run_analysis > 0, "Click 'Run Analysis' to compute results."))
      tryCatch(
        bgc_preview_datatable(table_fn(), digits = 4),
        error = function(e) bgc_preview_error_dt(paste("Results table failed:", conditionMessage(e)))
      )
    },
    server = FALSE
  )

  output$stats_plot <- renderPlot({
    validate(need(input$run_analysis > 0, "Click 'Run Analysis' to compute results."))
    if (is.null(plot_fn)) {
      plot.new()
      title(main = "No plot available for this module.")
      return(invisible(NULL))
    }
    plot_fn()
  })

  output$download_results <- downloadHandler(
    filename = function(){
      paste0(filename_prefix, "_", Sys.Date(), ".csv")
    },
    content = function(file){
      write.csv(table_fn(), file, row.names = FALSE)
    }
  )

  output$download_plot <- downloadHandler(
    filename = function(){
      paste0(filename_prefix, "_plot_", Sys.Date(), ".pdf")
    },
    content = function(file){
      grDevices::pdf(file, width = 8, height = 6)
      on.exit(grDevices::dev.off(), add = TRUE)
      if (is.null(plot_fn)) {
        plot.new()
        title(main = "No plot available for this module.")
      } else {
        plot_fn()
      }
    }
  )
}
