show_example_data_UI <- function(id){
  tagList(
    actionButton(
      inputId = NS(id, "preview_example_df_20230526"),
      label = "Preview Example",
      class = "btn btn-outline-info"
    ),
    tags$span(style = "display:inline-block; width: 8px;"),
    downloadBttn(
      outputId = NS(id, "download_example_df_20230526"),
      label = "Download Example",
      color = "primary",
      style = "bordered"
    ),
    tags$br(),
    tags$br(),
    DT::DTOutput(
      outputId = NS(id, "show_example_df_20230526")
    )
  )
}

show_example_data_Server <- function(id, data){
  moduleServer(id, function(input, output, session){
    preview_data <- eventReactive(input$preview_example_df_20230526, {
      get(data)
    })

    output$show_example_df_20230526 <- DT::renderDT({
      validate(
        need(
          !is.null(preview_data()),
          "Click 'Preview Example' to view the demo table."
        )
      )
      DT::datatable(
        preview_data(),
        rownames = FALSE,
        class = "compact stripe hover",
        options = list(
          pageLength = 10,
          lengthMenu = c(10, 25, 50, 100),
          scrollX = TRUE,
          dom = "tip"
        )
      )
    })

    output$download_example_df_20230526 <- downloadHandler(
      filename = function(){paste0(data, "_", id,"_example_", Sys.Date(),".csv")},
      content = function(file){
        utils::write.csv(
          get(data),
          file = file,
          row.names = FALSE,
          fileEncoding = "UTF-8"
        )
      }
    )
  })
}
