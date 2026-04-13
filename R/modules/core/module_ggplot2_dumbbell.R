ggplot2_dumbbell_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())
      sync_column_choices(
        session,
        df(),
        c("y_axis", "x_start", "x_end"),
        selected_map = list(
          y_axis  = bgc_pick_column(input$y_axis, discrete_cols[1]),
          x_start = bgc_pick_column(input$x_start, numeric_cols[1]),
          x_end   = bgc_pick_column(input$x_end, numeric_cols[2], numeric_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    dumbbell_data <- reactive({
      validate_required_columns(df(), c(input$y_axis, input$x_start, input$x_end))
      validate_numeric_columns(df(), c(input$x_start, input$x_end))

      data <- df()[, c(input$y_axis, input$x_start, input$x_end), drop = FALSE]
      names(data) <- c("category", "start_val", "end_val")
      data$category <- as.character(data$category)
      data$diff <- data$end_val - data$start_val

      data <- switch(
        input$sort_by,
        start = data[order(data$start_val), ],
        end   = data[order(data$end_val), ],
        diff  = data[order(data$diff), ],
        data
      )

      data$category <- factor(data$category, levels = data$category)
      data
    })

    build_dumbbell_plot <- function() {
      data <- dumbbell_data()

      p <- ggplot(data, aes(y = category)) +
        geom_segment(
          aes(x = start_val, xend = end_val, yend = category),
          color = input$segment_color,
          linewidth = input$segment_size
        ) +
        geom_point(
          aes(x = start_val, color = "start"),
          size = input$point_size,
          alpha = input$point_alpha
        ) +
        geom_point(
          aes(x = end_val, color = "end"),
          size = input$point_size,
          alpha = input$point_alpha
        ) +
        scale_color_manual(
          name = NULL,
          values = c(start = input$start_color, end = input$end_color),
          labels = c(start = input$start_label, end = input$end_label),
          breaks = c("start", "end")
        )

      if (input$show_diff == "Yes") {
        p <- p + geom_text(
          aes(
            x = (start_val + end_val) / 2,
            label = sprintf("%+.2f", diff)
          ),
          vjust = -0.8,
          size = input$label_size / 4
        )
      }

      p <- p +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          title = input$plot_title,
          subtitle = input$plot_subtitle
        ) +
        get(input$theme_choose)() +
        theme(text = element_text(size = input$label_size))

      p |> apply_plot_limits(input)
    }

    dumbbell_reac <- eventReactive(input$Plot, {
      p <- build_dumbbell_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, dumbbell_reac, vals, "Dumbbell_Plot")
  })
}
