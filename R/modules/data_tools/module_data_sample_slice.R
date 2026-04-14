data_tools_sample_slice_Server <- function(id){
  moduleServer(id, function(input, output, session){
    df <- uploaded_table_reactive(input)

    transformed <- eventReactive(input$apply_transform, {
      data <- df()
      n_rows <- nrow(data)
      validate(need(n_rows > 0, "Uploaded table is empty."))

      seed <- suppressWarnings(as.integer(input$seed))
      if (!is.na(seed)) set.seed(seed)
      replace <- identical(input$replace, "yes")

      switch(input$operation,
        sample_n = {
          n <- max(1L, as.integer(input$n))
          if (!replace) n <- min(n, n_rows)
          idx <- sample.int(n_rows, size = n, replace = replace)
          data[idx, , drop = FALSE]
        },
        sample_frac = {
          frac <- max(0.001, min(1, as.numeric(input$frac)))
          n <- max(1L, round(frac * n_rows))
          idx <- sample.int(n_rows, size = n, replace = replace)
          data[idx, , drop = FALSE]
        },
        slice = {
          from <- max(1L, as.integer(input$row_from))
          to   <- min(n_rows, as.integer(input$row_to))
          validate(need(from <= to, "'Slice from' must be <= 'Slice to'."))
          data[from:to, , drop = FALSE]
        },
        head = {
          n <- min(max(1L, as.integer(input$n)), n_rows)
          utils::head(data, n)
        },
        tail = {
          n <- min(max(1L, as.integer(input$n)), n_rows)
          utils::tail(data, n)
        }
      )
    })

    bind_data_tools_outputs(output, input, transformed, "sampled_data")
  })
}
