basic_data_tools_body <- function(inputid, fun){
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
        title = "Result",
        fluidPage(
          data_tools_result_UI(id = inputid)
        )
      )
    )
  )
}

basic_data_tools_UI <- function(tabName, inputid, title, fun){
  tabItem(
    tabName = tabName,
    header_tabItem(title = title),
    basic_data_tools_body(inputid, fun)
  )
}

data_tools_result_UI <- function(id){
  tagList(
    fluidRow(
      column(
        width = 12,
        align = "center",
        actionBttn(
          inputId = NS(id, "apply_transform"),
          label = "Apply Transform",
          color = "primary",
          style = "bordered",
          icon = icon("wand-magic-sparkles")
        )
      )
    ),
    tags$hr(),
    fluidRow(
      column(
        width = 12,
        uiOutput(NS(id, "transform_summary"))
      )
    ),
    tags$hr(),
    fluidRow(
      column(
        width = 12,
        tags$h4("Preview"),
        DT::DTOutput(NS(id, "transform_preview"))
      )
    ),
    tags$hr(),
    fluidRow(
      column(
        width = 12,
        align = "center",
        downloadButton(NS(id, "download_transformed"), "Download CSV")
      )
    )
  )
}

bind_data_tools_outputs <- function(output, input, transform_fn, filename_prefix, preview_rows = 20){
  output$transform_preview <- DT::renderDT(
    {
      validate(need(input$apply_transform > 0, "Click 'Apply Transform' to run."))
      tryCatch(
        bgc_preview_datatable(head(transform_fn(), preview_rows), digits = 4),
        error = function(e) bgc_preview_error_dt(paste("Preview failed:", conditionMessage(e)))
      )
    },
    server = FALSE
  )

  output$transform_summary <- renderUI({
    validate(need(input$apply_transform > 0, "Click 'Apply Transform' to run."))
    result <- transform_fn()
    tags$div(
      style = "padding: 12px 14px; border: 1px solid #d7dee7; border-radius: 12px; background: #f8fafc;",
      tags$div(
        style = "font-weight: 600; color: #1f3b5b; margin-bottom: 8px;",
        "Transform Summary"
      ),
      tags$p(
        style = "margin-bottom: 0;",
        sprintf(
          "Rows: %d | Columns: %d | Showing first %d rows in preview.",
          nrow(result),
          ncol(result),
          min(preview_rows, nrow(result))
        )
      )
    )
  })

  output$download_transformed <- downloadHandler(
    filename = function(){
      paste0(filename_prefix, "_", Sys.Date(), ".csv")
    },
    content = function(file){
      write.csv(transform_fn(), file, row.names = FALSE)
    }
  )
}
