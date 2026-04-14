ggplot2_slope_chart_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())
      sync_column_choices(
        session, df(),
        c("category_var","time_var","value_var","color_var"),
        selected_map = list(
          category_var = bgc_pick_column(input$category_var, discrete_cols[1]),
          time_var     = bgc_pick_column(input$time_var, discrete_cols[2], discrete_cols[1]),
          value_var    = bgc_pick_column(input$value_var, numeric_cols[1]),
          color_var    = bgc_pick_column(input$color_var, "")
        )
      )
    }, ignoreNULL = FALSE)

    slope_data <- reactive({
      validate_required_columns(df(), c(input$category_var, input$time_var, input$value_var))
      validate_numeric_columns(df(), input$value_var)

      cols <- c(input$category_var, input$time_var, input$value_var)
      color_col <- input$color_var
      if (!is.null(color_col) && nzchar(color_col)) cols <- c(cols, color_col)

      data <- df()[, cols, drop = FALSE]
      names(data)[1:3] <- c("category","time","value")
      if (length(cols) == 4) names(data)[4] <- "color_grp"

      data$category <- as.character(data$category)
      data$time <- factor(data$time, levels = unique(data$time))
      data
    })

    build_slope <- function(){
      data <- slope_data()
      mapping <- if ("color_grp" %in% names(data)) {
        aes(x = time, y = value, group = category, color = color_grp)
      } else {
        aes(x = time, y = value, group = category)
      }

      p <- ggplot(data, mapping) +
        geom_line(linewidth = input$line_size, alpha = 0.7) +
        geom_point(size = input$point_size)

      if (identical(input$show_labels, "yes")) {
        last_level <- levels(data$time)[length(levels(data$time))]
        end_data <- data[data$time == last_level, ]
        p <- p + geom_text(
          data = end_data,
          aes(label = category),
          hjust = -0.1,
          size = input$label_size / 4
        )
      }

      p <- p |> apply_color_scales(input)
      p <- add_standard_plot_labels(p, input,
                                    x_label = input$x_axis_Title,
                                    y_label = input$y_axis_Title)
      p |> apply_plot_limits(input)
    }

    slope_reac <- eventReactive(input$Plot, {
      p <- build_slope()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, slope_reac, vals, "Slope_Chart")
  })
}
