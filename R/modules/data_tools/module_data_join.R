data_tools_join_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    right_df <- reactive({
      req(input$right_file)
      file_info <- input$right_file
      sep <- input$right_separator
      is_xlsx <- identical(sep, "xlsx2") ||
                 grepl("\\.xlsx$", file_info$name, ignore.case = TRUE)
      tryCatch(
        if (is_xlsx) {
          as.data.frame(
            readxl::read_xlsx(path = file_info$datapath),
            check.names = FALSE
          )
        } else {
          read.csv(
            file = file_info$datapath,
            header = TRUE,
            sep = sep,
            quote = "\"",
            check.names = FALSE
          )
        },
        error = function(e) {
          stop(paste("Failed to read right table:", conditionMessage(e)), call. = FALSE)
        }
      )
    })

    observeEvent(df(), {
      sync_column_choices(
        session,
        df(),
        "left_key",
        selected_map = list(
          left_key = bgc_pick_column(input$left_key, names(df())[1])
        )
      )
    }, ignoreNULL = FALSE)

    observeEvent(right_df(), {
      right <- right_df()
      sync_column_choices(
        session,
        right,
        "right_key",
        selected_map = list(
          right_key = bgc_pick_column(input$right_key, names(right)[1])
        )
      )
    }, ignoreNULL = FALSE)

    joined <- eventReactive(input$apply_transform, {
      req(nzchar(input$left_key), nzchar(input$right_key))
      left  <- df()
      right <- right_df()

      validate_required_columns(left,  input$left_key,  data_label = "left table")
      validate_required_columns(right, input$right_key, data_label = "right table")

      key_pair <- setNames(input$right_key, input$left_key)
      type <- input$join_type

      join_args <- list(
        x = left,
        y = right,
        by.x = input$left_key,
        by.y = input$right_key,
        all.x = type %in% c("left", "full"),
        all.y = type %in% c("right", "full"),
        sort = FALSE
      )
      do.call(merge, join_args)
    })

    bind_data_tools_outputs(output, input, joined, "joined_data")
  })
}
