ggplot2_parcoord_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      current_axes <- input$axis_columns
      if (is.null(current_axes)) current_axes <- character()
      selected_axes <- intersect(current_axes, numeric_cols)
      if (length(selected_axes) == 0) selected_axes <- numeric_cols

      sync_multi_column_choices(session, df(), "axis_columns", selected = selected_axes)

      sync_column_choices(
        session,
        df(),
        "group_column",
        selected_map = list(
          group_column = bgc_pick_column(input$group_column, discrete_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    parcoord_inputs <- reactive({
      axes <- input$axis_columns
      validate(need(length(axes) >= 2, "Select at least two numeric axis columns."))
      validate_required_columns(df(), axes)
      validate_numeric_columns(df(), axes)

      group_col <- input$group_column
      if (!is.null(group_col) && nzchar(group_col) && group_col %in% names(df())) {
        validate_required_columns(df(), group_col)
      } else {
        group_col <- NULL
      }

      list(axes = axes, group = group_col)
    })

    build_parcoord_plot <- function() {
      cfg <- parcoord_inputs()
      data <- df()

      col_idx <- match(cfg$axes, names(data))
      group_idx <- if (!is.null(cfg$group)) match(cfg$group, names(data)) else NULL

      p <- GGally::ggparcoord(
        data,
        columns = col_idx,
        groupColumn = group_idx,
        scale = input$scale_method,
        order = input$axis_order,
        showPoints = input$show_points == "Yes",
        alphaLines = input$line_alpha,
        boxplot = input$show_boxplot == "Yes"
      )

      p$layers <- lapply(p$layers, function(layer) {
        if (inherits(layer$geom, "GeomLine")) {
          layer$aes_params$linewidth <- input$line_width
        }
        if (inherits(layer$geom, "GeomPoint")) {
          layer$aes_params$size <- input$point_size
        }
        layer
      })

      if (!is.null(input$discrete_color_choose) && input$discrete_color_choose != "") {
        p <- p + get(input$discrete_color_choose)()
      }

      p +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          title = input$plot_title,
          subtitle = input$plot_subtitle
        ) +
        get(input$theme_choose)() +
        theme(
          text = element_text(size = input$label_size),
          axis.text.x = element_text(angle = 30, hjust = 1)
        )
    }

    parcoord_reac <- eventReactive(input$Plot, {
      p <- build_parcoord_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, parcoord_reac, vals, "ParallelCoord_Plot")
  })
}
