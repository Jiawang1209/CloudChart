file_upload_UI <- function(id){
  tagList(
    fileInput(
      inputId = NS(id, "file_upload"),
      label = "Choose Input File",
      multiple = FALSE,
      accept = c(".csv", ".tsv", ".txt", ".xlsx", ".xls")
    ),
    tags$hr(),
    awesomeCheckbox(
      inputId = NS(id, "file_header"),
      label = "Header",
      value = TRUE
    ),
    tags$hr(),
    radioGroupButtons(
      inputId = NS(id, "file_separator"),
      label = "Format",
      choiceNames = c("Auto", "csv", "tsv", "xlsx"),
      choiceValues = c("auto", ",", "\t", "xlsx2"),
      selected = "auto",
      checkIcon = list(yes = tags$i(class = "fa fa-check-square",
                                    style = "color: steelblue"),
                       no = tags$i(class = "fa fa-square-o",
                                   style = "color: steelblue"))
    ),
    tags$hr(),
    radioGroupButtons(
      inputId = NS(id, "file_quote"),
      label = "Quote",
      choiceNames = c("Double Quote", "Single Quote", "None"),
      choiceValues = c("\"", "'", ""),
      selected = "\"",
      checkIcon = list(yes = tags$i(class = "fa fa-check-square",
                                    style = "color: steelblue"),
                       no = tags$i(class = "fa fa-square-o",
                                   style = "color: steelblue"))
    ),
    tags$hr(),
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
    DT::DTOutput(
      outputId = NS(id, "file_output")
    )
  )
}


bgc_upload_error_panel <- function(message) {
  tags$div(
    style = "padding: 12px 14px; border: 1px solid #f5c2c7; border-radius: 12px; background: #f8d7da; color: #842029;",
    tags$div(
      style = "font-weight: 600; margin-bottom: 6px;",
      "Upload failed"
    ),
    tags$p(
      style = "margin-bottom: 0; white-space: pre-wrap;",
      message
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

      frame <- df()
      summary_info <- tryCatch(
        bgc_data_summary(frame),
        error = function(e) NULL
      )

      if (is.null(summary_info)) {
        return(bgc_upload_error_panel(
          "Could not summarize the uploaded file. Check that the file has non-empty, uniquely named columns."
        ))
      }

      uploaded_name <- if (!is.null(input$file_upload)) input$file_upload$name else "-"

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
              paste0("File: ", uploaded_name)
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

    output$file_output <- DT::renderDT({
      validate(
        need(!is.null(df()), "Upload a file and click 'Submit File!' to preview data.")
      )

      tryCatch(
        DT::datatable(
          df(),
          rownames = FALSE,
          class = "compact stripe hover",
          options = list(
            pageLength = 10,
            lengthMenu = c(10, 25, 50, 100),
            scrollX = TRUE,
            dom = "lftip"
          )
        ),
        error = function(e) {
          DT::datatable(
            data.frame(Error = paste("Preview failed:", conditionMessage(e))),
            rownames = FALSE,
            options = list(dom = "t", ordering = FALSE)
          )
        }
      )
    })
  })
}
