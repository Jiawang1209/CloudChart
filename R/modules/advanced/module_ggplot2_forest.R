ggplot2_forest_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())
      sync_column_choices(
        session,
        df(),
        c("label_column", "estimate_column", "lower_column", "upper_column", "group_column"),
        selected_map = list(
          label_column    = bgc_pick_column(input$label_column, discrete_cols[1]),
          estimate_column = bgc_pick_column(input$estimate_column, numeric_cols[1]),
          lower_column    = bgc_pick_column(input$lower_column, numeric_cols[2], numeric_cols[1]),
          upper_column    = bgc_pick_column(input$upper_column, numeric_cols[3], numeric_cols[2], numeric_cols[1]),
          group_column    = bgc_pick_column(input$group_column)
        )
      )
    }, ignoreNULL = FALSE)

    forest_data <- reactive({
      required <- c(input$label_column, input$estimate_column, input$lower_column, input$upper_column)
      validate(need(all(nzchar(required)), "Set label, estimate, lower and upper columns before plotting."))
      validate_required_columns(df(), required)
      validate_numeric_columns(df(), c(input$estimate_column, input$lower_column, input$upper_column))

      data <- df()[, required, drop = FALSE]
      names(data) <- c("label", "estimate", "lower", "upper")
      data$label <- as.character(data$label)

      group_col <- input$group_column
      if (!is.null(group_col) && nzchar(group_col) && group_col %in% names(df())) {
        data$group <- as.character(df()[[group_col]])
      } else {
        data$group <- NA_character_
      }

      data$label <- factor(data$label, levels = rev(unique(data$label)))
      data
    })

    build_forest_plot <- function() {
      data <- forest_data()
      has_group <- any(!is.na(data$group))

      p <- ggplot(data, aes(x = estimate, y = label)) +
        geom_vline(
          xintercept = input$ref_value,
          linetype = input$ref_linetype,
          color = input$ref_color
        ) +
        geom_errorbarh(
          aes(xmin = lower, xmax = upper),
          height = 0.25,
          linewidth = input$whisker_width,
          color = if (has_group) NA else input$point_color
        )

      if (has_group) {
        p <- p + geom_errorbarh(
          aes(xmin = lower, xmax = upper, color = group),
          height = 0.25,
          linewidth = input$whisker_width
        ) +
          geom_point(aes(color = group), size = input$point_size)
      } else {
        p <- p + geom_point(
          size = input$point_size,
          color = input$point_color
        )
      }

      if (input$show_values == "Yes") {
        p <- p + geom_text(
          aes(label = sprintf("%.2f [%.2f, %.2f]", estimate, lower, upper)),
          hjust = -0.1,
          size = input$label_size / 4,
          nudge_x = 0
        )
      }

      if (input$log_scale == "log10") {
        p <- p + scale_x_log10()
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
        theme(
          text = element_text(size = input$label_size),
          panel.grid.major.y = element_blank()
        )

      if (!is.null(input$x_limite) && !all(is.na(input$x_limite))) {
        p <- p + xlim(input$x_limite[1], input$x_limite[2])
      }

      p
    }

    forest_reac <- eventReactive(input$Plot, {
      p <- build_forest_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, forest_reac, vals, "Forest_Plot")
  })
}
