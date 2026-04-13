ggplot2_bump_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())
      sync_column_choices(
        session,
        df(),
        c("x_axis", "y_axis", "group_column"),
        selected_map = list(
          x_axis       = bgc_pick_column(input$x_axis, numeric_cols[1], names(df())[1]),
          y_axis       = bgc_pick_column(input$y_axis, numeric_cols[2], numeric_cols[1]),
          group_column = bgc_pick_column(input$group_column, discrete_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    bump_data <- reactive({
      required <- c(input$x_axis, input$y_axis, input$group_column)
      validate(need(all(nzchar(required)), "Set x, y and group columns before plotting."))
      validate_required_columns(df(), required)
      validate_numeric_columns(df(), input$y_axis)

      data <- df()[, required, drop = FALSE]
      names(data) <- c("x", "y", "group")
      data$group <- as.character(data$group)

      if (input$value_mode == "rank") {
        data <- data %>%
          dplyr::group_by(x) %>%
          dplyr::mutate(rank = rank(-y, ties.method = "first")) %>%
          dplyr::ungroup()
        data$plot_y <- data$rank
      } else {
        data$plot_y <- data$y
      }

      data
    })

    build_bump_plot <- function() {
      data <- bump_data()

      p <- ggplot(data, aes(x = x, y = plot_y, color = group, group = group)) +
        ggbump::geom_bump(
          linewidth = input$line_size,
          smooth = input$smooth,
          alpha = input$line_alpha
        ) +
        geom_point(size = input$point_size)

      if (input$show_labels == "Yes") {
        end_df <- data[data$x == max(data$x, na.rm = TRUE), , drop = FALSE]
        start_df <- data[data$x == min(data$x, na.rm = TRUE), , drop = FALSE]
        p <- p +
          geom_text(
            data = start_df,
            aes(label = group),
            hjust = 1.1,
            size = input$label_size / 4
          ) +
          geom_text(
            data = end_df,
            aes(label = group),
            hjust = -0.1,
            size = input$label_size / 4
          )
      }

      if (input$value_mode == "rank" || input$reverse_y == "Yes") {
        p <- p + scale_y_reverse()
      }

      if (!is.null(input$discrete_color_choose) && input$discrete_color_choose != "") {
        p <- p + get(input$discrete_color_choose)()
      }

      p <- p +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          title = input$plot_title,
          subtitle = input$plot_subtitle,
          color = input$group_column
        ) +
        get(input$theme_choose)() +
        theme(text = element_text(size = input$label_size))

      p |> apply_plot_limits(input)
    }

    bump_reac <- eventReactive(input$Plot, {
      p <- build_bump_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, bump_reac, vals, "Bump_Plot")
  })
}
