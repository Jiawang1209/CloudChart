ggplot2_upset_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      discrete_cols <- bgc_discrete_columns(df())
      sync_column_choices(
        session,
        df(),
        c("value_column", "group_column"),
        selected_map = list(
          value_column = bgc_pick_column(input$value_column, names(df())[1]),
          group_column = bgc_pick_column(input$group_column, discrete_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    upset_wide <- reactive({
      validate_required_columns(df(), c(input$value_column, input$group_column))

      values <- as.character(df()[[input$value_column]])
      groups <- as.character(df()[[input$group_column]])
      set_names <- unique(groups)

      validate(need(length(set_names) >= 2, "Group column must contain at least 2 distinct groups."))

      membership <- lapply(set_names, function(g) unique(values[groups == g]))
      names(membership) <- set_names
      universe <- unique(unlist(membership))

      wide <- data.frame(
        `__id__` = universe,
        check.names = FALSE,
        stringsAsFactors = FALSE
      )
      for (g in set_names) {
        wide[[g]] <- universe %in% membership[[g]]
      }
      list(data = wide, sets = set_names)
    })

    build_upset_plot <- function() {
      wide <- upset_wide()

      sort_int <- if (input$sort_intersections == "none") FALSE else input$sort_intersections
      sort_set <- if (input$sort_sets == "none") FALSE else input$sort_sets

      p <- ComplexUpset::upset(
        data = wide$data,
        intersect = wide$sets,
        min_size = input$min_size,
        sort_intersections = sort_int,
        sort_sets = sort_set,
        base_annotations = list(
          "Intersection size" = ComplexUpset::intersection_size(
            fill = input$bar_fill
          )
        ),
        themes = ComplexUpset::upset_default_themes(
          text = element_text(size = input$label_size)
        )
      )

      p <- p + patchwork::plot_annotation(
        title = input$plot_title,
        subtitle = input$plot_subtitle
      )
      p
    }

    upset_reac <- eventReactive(input$Plot, {
      p <- build_upset_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, upset_reac, vals, "UpSet_Plot")
  })
}
