ggplot2_boxplot_Server <- function(id){
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
          x_axis = bgc_pick_column(input$x_axis, discrete_cols[1]),
          y_axis = bgc_pick_column(input$y_axis, numeric_cols[1]),
          fill_variable = bgc_pick_column(input$fill_variable, discrete_cols[2], discrete_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    box_mapping <- reactive({
      req(input$x_axis != "", input$y_axis != "")
      validate_required_columns(df(), c(input$x_axis, input$y_axis, input$fill_variable))

      mapping <- aes(
        x = .data[[input$x_axis]],
        y = .data[[input$y_axis]]
      )

      if (input$fill_variable != "") {
        mapping$fill <- rlang::expr(.data[[!!input$fill_variable]])
      }

      mapping
    })

    build_box_plot <- function() {
      p <- ggplot(df(), box_mapping()) +
        stat_boxplot(
          geom = "errorbar",
          width = input$errobar_width,
          color = input$border_color,
          linewidth = input$box_width,
          show.legend = FALSE
        )

      box_args <- list(
        notch = identical(input$box_shape, "Yes"),
        width = input$box_width,
        color = input$border_color,
        linewidth = input$line_width,
        alpha = input$alpha
      )

      if (input$fill_variable == "") {
        box_args$fill <- input$fill_color
      }

      p <- p + do.call(geom_boxplot, box_args)

      if (input$add_point == "Yes") {
        p <- p + geom_jitter(
          alpha = input$point_alpha,
          show.legend = FALSE,
          size = input$point_size
        )
      }

      p |>
        add_standard_plot_labels(input) |>
        apply_fill_scales(input) |>
        apply_plot_limits(input)
    }

    dot_plot_reac <- eventReactive(input$Plot,{
      p <- build_box_plot()
      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "Box_Plot")
    
  })
  
}
