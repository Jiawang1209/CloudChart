ggplot2_treemap_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())
      sync_column_choices(
        session,
        df(),
        c("area_variable", "fill_variable", "label_variable", "subgroup_variable"),
        selected_map = list(
          area_variable     = bgc_pick_column(input$area_variable, numeric_cols[1]),
          fill_variable     = bgc_pick_column(input$fill_variable, discrete_cols[1]),
          label_variable    = bgc_pick_column(input$label_variable, discrete_cols[1]),
          subgroup_variable = bgc_pick_column(input$subgroup_variable)
        )
      )
    }, ignoreNULL = FALSE)

    treemap_data <- reactive({
      required <- c(input$area_variable, input$fill_variable, input$label_variable)
      validate(need(all(nzchar(required)), "Set area, fill and label variables before plotting."))
      validate_required_columns(df(), required)
      validate_numeric_columns(df(), input$area_variable)
      df()
    })

    build_treemap_plot <- function() {
      data <- treemap_data()

      has_subgroup <- !is.null(input$subgroup_variable) && nzchar(input$subgroup_variable) &&
        input$subgroup_variable %in% names(data)

      mapping <- aes(
        area  = .data[[input$area_variable]],
        fill  = .data[[input$fill_variable]],
        label = .data[[input$label_variable]]
      )
      if (has_subgroup) {
        mapping$subgroup <- rlang::sym(input$subgroup_variable)
      }

      p <- ggplot(data, mapping) +
        treemapify::geom_treemap(
          layout = input$layout,
          color = input$tile_border_color,
          size = input$tile_border_width
        )

      if (input$show_value == "Yes") {
        p <- p + treemapify::geom_treemap_text(
          aes(label = paste0(
            .data[[input$label_variable]],
            "\n",
            .data[[input$area_variable]]
          )),
          place = input$place,
          grow = input$grow_label == "Yes",
          colour = input$label_color,
          size = input$label_size,
          layout = input$layout
        )
      } else {
        p <- p + treemapify::geom_treemap_text(
          place = input$place,
          grow = input$grow_label == "Yes",
          colour = input$label_color,
          size = input$label_size,
          layout = input$layout
        )
      }

      if (has_subgroup) {
        p <- p + treemapify::geom_treemap_subgroup_border(
          colour = "#000000",
          layout = input$layout
        )
      }

      if (!is.null(input$discrete_fill_choose) && input$discrete_fill_choose != "") {
        p <- p + get(input$discrete_fill_choose)()
      }

      p +
        labs(
          title = input$plot_title,
          subtitle = input$plot_subtitle,
          fill = input$fill_variable
        ) +
        get(input$theme_choose)() +
        theme(text = element_text(size = input$label_size))
    }

    treemap_reac <- eventReactive(input$Plot, {
      p <- build_treemap_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, treemap_reac, vals, "Treemap_Plot")
  })
}
