ggplot2_stacked_area_Server <- function(id){
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
          x_axis = bgc_pick_column(input$x_axis, discrete_cols[1], numeric_cols[1]),
          y_axis = bgc_pick_column(input$y_axis, numeric_cols[1]),
          fill_variable = bgc_pick_column(input$fill_variable, discrete_cols[2], discrete_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    area_data <- reactive({
      req(input$x_axis != "", input$y_axis != "", input$fill_variable != "")
      validate_required_columns(df(), c(input$x_axis, input$y_axis, input$fill_variable))
      validate_numeric_columns(df(), input$y_axis)

      data_subset <- df()[, c(input$x_axis, input$fill_variable, input$y_axis), drop = FALSE]
      names(data_subset) <- c("x_col", "fill_col", "y_col")
      summarised <- dplyr::summarise(
        dplyr::group_by(data_subset, x_col, fill_col),
        y_col = sum(y_col, na.rm = TRUE),
        .groups = "drop"
      )
      names(summarised) <- c(input$x_axis, input$fill_variable, input$y_axis)
      summarised
    })

    build_stacked_area <- function() {
      data <- area_data()

      p <- ggplot(data, aes(
        x = .data[[input$x_axis]],
        y = .data[[input$y_axis]],
        fill = .data[[input$fill_variable]],
        group = .data[[input$fill_variable]]
      )) +
        geom_area(
          position = input$stack_position,
          alpha = input$alpha,
          color = input$line_color,
          size = input$line_size
        )

      p |>
        add_standard_plot_labels(input) |>
        apply_fill_scales(input) |>
        apply_plot_limits(input)
    }

    area_reac <- eventReactive(input$Plot, {
      p <- build_stacked_area()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, area_reac, vals, "Stacked_Area_Plot")
  })
}
