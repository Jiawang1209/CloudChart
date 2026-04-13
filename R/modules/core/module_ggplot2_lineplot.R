ggplot2_lineplot_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session,
        df(),
        c("x_axis", "y_axis", "group_variable", "color_variable", "linetype_variable"),
        selected_map = list(
          x_axis = bgc_pick_column(input$x_axis, discrete_cols[1], numeric_cols[1]),
          y_axis = bgc_pick_column(input$y_axis, numeric_cols[1]),
          group_variable = bgc_pick_column(input$group_variable, discrete_cols[1]),
          color_variable = bgc_pick_column(input$color_variable, discrete_cols[1]),
          linetype_variable = bgc_pick_column(input$linetype_variable, discrete_cols[2], discrete_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    line_mapping <- reactive({
      req(input$x_axis != "", input$y_axis != "")
      validate_required_columns(
        df(),
        c(input$x_axis, input$y_axis, input$group_variable, input$color_variable, input$linetype_variable)
      )

      mapping <- aes(
        x = .data[[input$x_axis]],
        y = .data[[input$y_axis]]
      )

      if (input$group_variable != "") {
        mapping$group <- rlang::expr(.data[[!!input$group_variable]])
      }

      if (input$color_variable != "") {
        mapping$color <- rlang::expr(.data[[!!input$color_variable]])
      }

      if (input$linetype_variable != "") {
        mapping$linetype <- rlang::expr(.data[[!!input$linetype_variable]])
      }

      mapping
    })

    build_line_plot <- function() {
      line_args <- list(size = input$border_width)
      if (input$color_variable == "") {
        line_args$color <- input$border_color
      }

      p <- ggplot(df(), line_mapping()) +
        do.call(geom_line, line_args)

      if (input$add_point == "Yes") {
        point_args <- list(
          shape = 21,
          size = input$point_size,
          stroke = input$point_width
        )

        if (input$color_variable != "") {
          point_args$mapping <- aes(fill = .data[[input$color_variable]])
        } else {
          point_args$color <- input$border_color
          point_args$fill <- input$fill_color
        }

        p <- p + do.call(geom_point, point_args)
      }

      p |>
        add_standard_plot_labels(input) |>
        apply_fill_scales(input) |>
        apply_plot_limits(input)
    }

    dot_plot_reac <- eventReactive(input$Plot,{
      p <- build_line_plot()
      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "Line_Plot")
    
  })
  
}
