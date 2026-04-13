ggplot2_venn_Server <- function(id){
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

    venn_sets <- reactive({
      validate_required_columns(df(), c(input$value_column, input$group_column))

      values <- df()[[input$value_column]]
      groups <- as.character(df()[[input$group_column]])

      set_list <- split(as.character(values), groups)
      set_list <- lapply(set_list, function(x) unique(stats::na.omit(x)))

      validate(
        need(length(set_list) >= 2, "Group column must contain at least 2 distinct groups."),
        need(length(set_list) <= 7, "Venn diagrams support at most 7 sets; use UpSet for larger cases.")
      )
      set_list
    })

    build_venn_plot <- function() {
      sets <- venn_sets()

      label_type <- switch(
        input$count_style,
        count = "count",
        percent = "percent",
        both = "both",
        none = "none"
      )

      p <- ggVennDiagram::ggVennDiagram(
        sets,
        label = label_type,
        label_size = input$cell_label_size,
        set_size = input$set_label_size,
        edge_size = input$edge_width,
        edge_color = input$edge_color
      ) +
        ggplot2::scale_fill_gradient(low = input$low_color, high = input$high_color) +
        labs(
          title = input$plot_title,
          subtitle = input$plot_subtitle
        ) +
        get(input$theme_choose)() +
        theme(
          text = element_text(size = input$label_size),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          panel.grid = element_blank()
        )

      p
    }

    venn_reac <- eventReactive(input$Plot, {
      p <- build_venn_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, venn_reac, vals, "Venn_Plot")
  })
}
