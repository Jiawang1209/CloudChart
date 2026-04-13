file_upload_UI <- function(id){
  tagList(
    fileInput(
      inputId = NS(id, "file_upload"), 
      label = "Choose Input File",
      multiple = FALSE, 
      accept = c(".tsv",".csv",".xlsx")
    ),
    # Horizontal line
    tags$hr(),
    # Input: Checkbox if file own header
    awesomeCheckbox(
      inputId = NS(id, "file_header"), 
      label = "Header",
      value = TRUE
    ),
    # Horizontal line
    tags$hr(),
    # Input: Select separator
    radioGroupButtons(
      inputId = NS(id, "file_separator"),
      label = "Separator",
      choiceNames = c("csv","txt","xlsx"),
      choiceValues = c(",", "\t", "xlsx2"),
      checkIcon = list(yes = tags$i(class = "fa fa-check-square",
                                    style = "color: steelblue"),
                       no = tags$i(class = "fa fa-square-o", 
                                   style = "color: steelblue")
                       ),
                      ),
    tags$hr(),
    # Input: Select quotes
    radioGroupButtons(
      inputId = NS(id, "file_quote"),
      label = "Quote",
      choiceNames = c('None','Double Quote','Single Quote'),
      choiceValues = c('', '"', "'"),
      checkIcon = list(yes = tags$i(class = "fa fa-check-square",
                                    style = "color: steelblue"),
                       no = tags$i(class = "fa fa-square-o", 
                                   style = "color: steelblue"))
    ),
    tags$hr(),
    # Input: Select number of rows to display
    radioGroupButtons(
      inputId = NS(id, "file_display"), 
      label = "Display",
      choiceNames = c("Head","All"),
      choiceValues = c("head", "all"),
      checkIcon = list(yes = tags$i(class = "fa fa-check-square",
                                    style = "color: steelblue"),
                       no = tags$i(class = "fa fa-square-o", 
                                   style = "color: steelblue"))
    ),
    tags$hr(),
    # Submit file
    actionButton(
      inputId = NS(id, "submit_file"),
      label = "Submit File!",
      status = "info"
      )
  )
}

file_upload_show_UI <- function(id){
  tagList(
    uiOutput(
      outputId = NS(id, "file_summary")
    ),
    tags$br(),
    tableOutput(
      outputId = NS(id, "file_output")
      )
  )
}


file_upload_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    output$file_summary <- renderUI({
      validate(
        need(!is.null(df()), "Upload a file and click 'Submit File!' to view the data summary.")
      )

      summary_info <- bgc_data_summary(df())

      fluidRow(
        column(
          width = 12,
          tags$div(
            style = "padding: 12px 14px; border: 1px solid #d7dee7; border-radius: 12px; background: #f8fafc;",
            tags$div(
              style = "font-weight: 600; color: #1f3b5b; margin-bottom: 8px;",
              "Data Summary"
            ),
            tags$p(
              style = "margin-bottom: 6px;",
              paste0(
                "Rows: ", summary_info$rows,
                " | Columns: ", summary_info$columns,
                " | Numeric: ", summary_info$numeric_count,
                " | Category: ", summary_info$discrete_count,
                " | Missing Cells: ", summary_info$missing_cells
              )
            ),
            tags$p(
              style = "margin-bottom: 6px;",
              paste0(
                "Recommended mapping: x = ",
                ifelse(nzchar(summary_info$recommended_x), summary_info$recommended_x, "-"),
                ", y = ",
                ifelse(nzchar(summary_info$recommended_y), summary_info$recommended_y, "-"),
                ", group/fill = ",
                ifelse(nzchar(summary_info$recommended_group), summary_info$recommended_group, "-")
              )
            ),
            tags$p(
              style = "margin-bottom: 6px;",
              paste0(
                "Numeric columns: ",
                if (length(summary_info$numeric_cols) > 0) {
                  paste(utils::head(summary_info$numeric_cols, 6), collapse = ", ")
                } else {
                  "-"
                }
              )
            ),
            tags$p(
              style = "margin-bottom: 0;",
              paste0(
                "Category columns: ",
                if (length(summary_info$discrete_cols) > 0) {
                  paste(utils::head(summary_info$discrete_cols, 6), collapse = ", ")
                } else {
                  "-"
                }
              )
            )
          )
        )
      )
    })
    
    output$file_output <- renderTable({
      validate(
        need(!is.null(df()), "Upload a file and click 'Submit File!' to preview data.")
      )

      if (input$file_display == "head") {
        return(head(df()))
      }else{
        return(df())
      }
    })
  })
}
