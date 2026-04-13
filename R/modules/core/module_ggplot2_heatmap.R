ggplot2_heatmap_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session,
        df(),
        c("x_axis", "y_axis", "fill_variable"),
        selected_map = list(
          x_axis = bgc_pick_column(input$x_axis, discrete_cols[1], names(df())[1]),
          y_axis = bgc_pick_column(input$y_axis, discrete_cols[2], discrete_cols[1]),
          fill_variable = bgc_pick_column(input$fill_variable, numeric_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    heatmap_data <- reactive({
      req(input$x_axis != "", input$y_axis != "", input$fill_variable != "")
      validate(
        need(
          input$x_axis != input$fill_variable && input$y_axis != input$fill_variable,
          "Fill variable must differ from the x and y variables."
        )
      )
      validate_required_columns(df(), c(input$x_axis, input$y_axis, input$fill_variable))
      validate_numeric_columns(df(), input$fill_variable)

      data_subset <- df()[, c(input$x_axis, input$y_axis, input$fill_variable), drop = FALSE]
      names(data_subset) <- c("x_col", "y_col", "fill_col")
      agg_fn <- match.fun(input$aggregate_fun)
      summarised <- dplyr::summarise(
        dplyr::group_by(data_subset, x_col, y_col),
        fill_col = agg_fn(fill_col, na.rm = TRUE),
        .groups = "drop"
      )
      names(summarised) <- c(input$x_axis, input$y_axis, input$fill_variable)
      summarised
    })

    build_heatmap <- function() {
      data <- heatmap_data()

      p <- ggplot(data, aes(
        x = .data[[input$x_axis]],
        y = .data[[input$y_axis]],
        fill = .data[[input$fill_variable]]
      )) +
        geom_tile(color = "white")

      if (input$show_label == "Yes") {
        p <- p + geom_text(
          aes(label = round(.data[[input$fill_variable]], input$label_digits)),
          color = input$label_color,
          size = input$label_size / 4
        )
      }

      if (input$use_midpoint == "Yes") {
        midpoint_val <- mean(range(data[[input$fill_variable]], na.rm = TRUE))
        p <- p + scale_fill_gradient2(
          low = input$low_color,
          mid = input$mid_color,
          high = input$high_color,
          midpoint = midpoint_val
        )
      } else {
        p <- p + scale_fill_gradient(low = input$low_color, high = input$high_color)
      }

      p +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          title = input$plot_title,
          subtitle = input$plot_subtitle
        ) +
        get(input$theme_choose)() +
        theme(text = element_text(size = input$label_size))
    }

    heatmap_reac <- eventReactive(input$Plot, {
      p <- build_heatmap()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, heatmap_reac, vals, "Heatmap_Plot")
  })
}
