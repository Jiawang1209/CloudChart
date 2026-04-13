ggplot2_waterfall_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      sync_column_choices(
        session,
        df(),
        c("x_axis", "y_axis"),
        selected_map = list(
          x_axis = bgc_pick_column(input$x_axis, bgc_discrete_columns(df())[1]),
          y_axis = bgc_pick_column(input$y_axis, bgc_numeric_columns(df())[1])
        )
      )
    }, ignoreNULL = FALSE)

    waterfall_data <- reactive({
      validate_required_columns(df(), c(input$x_axis, input$y_axis))
      validate_numeric_columns(df(), input$y_axis)

      raw <- df()[, c(input$x_axis, input$y_axis), drop = FALSE]
      names(raw) <- c("category", "value")
      raw$category <- as.character(raw$category)

      if (input$show_total == "Yes") {
        total_label <- if (nzchar(input$total_label)) input$total_label else "Total"
        raw <- rbind(raw, data.frame(category = total_label, value = sum(raw$value, na.rm = TRUE)))
      }

      raw$order <- seq_len(nrow(raw))
      raw$end <- cumsum(raw$value)
      raw$start <- raw$end - raw$value

      if (input$show_total == "Yes") {
        total_label <- if (nzchar(input$total_label)) input$total_label else "Total"
        last_row <- nrow(raw)
        raw$start[last_row] <- 0
        raw$end[last_row]   <- raw$value[last_row]
      }

      raw$type <- ifelse(raw$value >= 0, "Positive", "Negative")
      if (input$show_total == "Yes") {
        raw$type[nrow(raw)] <- "Total"
      }

      raw$category <- factor(raw$category, levels = raw$category)
      raw
    })

    build_waterfall_plot <- function() {
      data <- waterfall_data()

      fill_values <- c(
        Positive = input$pos_color,
        Negative = input$neg_color,
        Total    = input$total_color
      )

      p <- ggplot(data) +
        geom_rect(
          aes(
            xmin = as.numeric(category) - input$bar_width / 2,
            xmax = as.numeric(category) + input$bar_width / 2,
            ymin = start,
            ymax = end,
            fill = type
          ),
          alpha = input$bar_alpha
        ) +
        scale_fill_manual(values = fill_values, drop = FALSE)

      if (nrow(data) > 1) {
        connector_df <- data.frame(
          x    = as.numeric(data$category)[-nrow(data)] + input$bar_width / 2,
          xend = as.numeric(data$category)[-1] - input$bar_width / 2,
          y    = data$end[-nrow(data)],
          yend = data$end[-nrow(data)]
        )
        p <- p + geom_segment(
          data = connector_df,
          aes(x = x, xend = xend, y = y, yend = yend),
          linetype = input$connector_linetype,
          color = input$connector_color,
          linewidth = input$connector_width
        )
      }

      if (input$show_labels == "Yes") {
        p <- p + geom_text(
          aes(
            x = as.numeric(category),
            y = pmax(start, end) + (max(data$end, na.rm = TRUE) - min(data$start, na.rm = TRUE)) * 0.02,
            label = round(value, 2)
          ),
          size = input$label_size / 4
        )
      }

      p <- p +
        scale_x_continuous(
          breaks = seq_len(nrow(data)),
          labels = as.character(data$category)
        ) +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          title = input$plot_title,
          subtitle = input$plot_subtitle,
          fill = NULL
        ) +
        get(input$theme_choose)() +
        theme(
          text = element_text(size = input$label_size),
          axis.text.x = element_text(angle = 30, hjust = 1)
        )

      p |> apply_plot_limits(input)
    }

    waterfall_reac <- eventReactive(input$Plot, {
      p <- build_waterfall_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, waterfall_reac, vals, "Waterfall_Plot")
  })
}
