ggplot2_bubble_plot_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session,
        df(),
        c("x_axis", "y_axis", "fill_variable", "shape_variable", "size_variable"),
        selected_map = list(
          x_axis = bgc_pick_column(input$x_axis, numeric_cols[1]),
          y_axis = bgc_pick_column(input$y_axis, numeric_cols[2]),
          fill_variable = bgc_pick_column(input$fill_variable, discrete_cols[1], numeric_cols[3]),
          shape_variable = bgc_pick_column(input$shape_variable, discrete_cols[2], discrete_cols[1]),
          size_variable = bgc_pick_column(input$size_variable, numeric_cols[3], numeric_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    bubble_mapping <- reactive({
      req(input$x_axis != "", input$y_axis != "")
      validate_required_columns(
        df(),
        c(input$x_axis, input$y_axis, input$fill_variable, input$shape_variable, input$size_variable)
      )
      validate_shape_range(input)

      if (identical(input$fill_class, "isNumeric") && nzchar(input$fill_variable)) {
        validate_numeric_columns(df(), input$fill_variable)
      }

      if (nzchar(input$size_variable)) {
        validate_numeric_columns(df(), input$size_variable)
      }

      mapping <- aes(
        x = .data[[input$x_axis]],
        y = .data[[input$y_axis]]
      )

      if (input$fill_variable != "") {
        if (input$fill_class == "isCharacter") {
          mapping$fill <- rlang::expr(factor(.data[[!!input$fill_variable]]))
        } else {
          mapping$fill <- rlang::expr(.data[[!!input$fill_variable]])
        }
      }

      if (input$shape_variable != "") {
        mapping$shape <- rlang::expr(.data[[!!input$shape_variable]])
      }

      if (input$size_variable != "") {
        mapping$size <- rlang::expr(.data[[!!input$size_variable]])
      }

      mapping
    })

    build_bubble_plot <- function() {
      point_args <- list(
        alpha = input$alpha,
        color = input$color
      )

      if (input$size_variable == "") {
        point_args$size <- input$demo_size[1]
      }

      if (input$fill_variable != "" && input$shape_variable == "") {
        point_args$shape <- 21
      }

      p <- ggplot(df(), bubble_mapping()) +
        do.call(geom_point, point_args)

      if (input$size_variable != "") {
        p <- p + scale_size(range = c(input$demo_size[1], input$demo_size[2]))
      }

      if (input$shape_variable != "") {
        p <- p + scale_shape_manual(values = input$shape_value[1]:input$shape_value[2])
      }

      p |>
        add_standard_plot_labels(input) |>
        apply_fill_scales(input) |>
        apply_plot_limits(input)
    }

    dot_plot_reac <- eventReactive(input$Plot,{
      p <- build_bubble_plot()
      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "Bubble_Plot")
    
  })
  
}
