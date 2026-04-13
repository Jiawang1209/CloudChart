ggplot2_sankey_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      discrete_cols <- bgc_discrete_columns(df())
      numeric_cols  <- bgc_numeric_columns(df())

      default_axes <- head(discrete_cols, 3)
      current <- input$axis_columns
      if (is.null(current)) current <- character()
      selected_axes <- intersect(current, names(df()))
      if (length(selected_axes) == 0) selected_axes <- default_axes

      sync_multi_column_choices(session, df(), "axis_columns", selected = selected_axes)

      sync_column_choices(
        session,
        df(),
        c("weight_variable", "fill_variable"),
        selected_map = list(
          weight_variable = bgc_pick_column(input$weight_variable, numeric_cols[1]),
          fill_variable   = bgc_pick_column(input$fill_variable, default_axes[1])
        )
      )
    }, ignoreNULL = FALSE)

    sankey_data <- reactive({
      axes <- input$axis_columns
      validate(need(length(axes) >= 2, "Select at least two categorical axis columns."))
      validate_required_columns(df(), axes)

      data <- df()[, axes, drop = FALSE]
      data[] <- lapply(data, as.character)

      weight_col <- input$weight_variable
      if (!is.null(weight_col) && nzchar(weight_col) && weight_col %in% names(df())) {
        validate_numeric_columns(df(), weight_col)
        data$`__weight__` <- df()[[weight_col]]
      } else {
        data$`__weight__` <- 1
      }

      fill_col <- input$fill_variable
      if (!is.null(fill_col) && nzchar(fill_col) && fill_col %in% names(df())) {
        data$`__fill__` <- as.character(df()[[fill_col]])
      } else {
        data$`__fill__` <- data[[axes[1]]]
      }

      data
    })

    build_sankey_plot <- function() {
      data <- sankey_data()
      axes <- input$axis_columns

      axis_args <- stats::setNames(
        lapply(axes, function(nm) rlang::sym(nm)),
        paste0("axis", seq_along(axes))
      )
      mapping <- aes(
        y = .data[["__weight__"]],
        fill = .data[["__fill__"]],
        !!!axis_args
      )

      p <- ggplot(data, mapping) +
        ggalluvial::geom_alluvium(
          alpha = input$alluvium_alpha,
          curve_type = input$curve_type,
          width = input$stratum_width
        ) +
        ggalluvial::geom_stratum(
          alpha = input$stratum_alpha,
          fill  = input$stratum_fill,
          color = input$stratum_border,
          width = input$stratum_width
        )

      if (input$show_stratum_label == "Yes") {
        p <- p + geom_text(
          stat = "stratum",
          aes(label = after_stat(stratum)),
          size = input$label_size / 4
        )
      }

      p <- p + scale_x_discrete(limits = axes, expand = c(0.05, 0.05))

      if (!is.null(input$discrete_fill_choose) && input$discrete_fill_choose != "") {
        p <- p + get(input$discrete_fill_choose)()
      }

      p +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          title = input$plot_title,
          subtitle = input$plot_subtitle,
          fill = input$fill_variable
        ) +
        get(input$theme_choose)() +
        theme(text = element_text(size = input$label_size))
    }

    sankey_reac <- eventReactive(input$Plot, {
      p <- build_sankey_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, sankey_reac, vals, "Sankey_Plot")
  })
}
