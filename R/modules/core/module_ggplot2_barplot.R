ggplot2_barplot_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      discrete_cols <- bgc_discrete_columns(df())

      sync_column_choices(
        session,
        df(),
        c("x_axis", "y_axis", "group_variable", "fill_variable"),
        selected_map = list(
          x_axis = bgc_pick_column(input$x_axis, discrete_cols[1]),
          y_axis = bgc_pick_column(input$y_axis, numeric_cols[1]),
          group_variable = bgc_pick_column(input$group_variable, discrete_cols[2], discrete_cols[1]),
          fill_variable = bgc_pick_column(input$fill_variable, discrete_cols[2], discrete_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    bar_mapping <- reactive({
      req(input$x_axis != "", input$y_axis != "")
      validate_required_columns(df(), c(input$x_axis, input$y_axis, input$group_variable, input$fill_variable))

      mapping <- aes(
        x = .data[[input$x_axis]],
        y = .data[[input$y_axis]]
      )

      if (input$group_variable != "") {
        mapping$group <- rlang::expr(.data[[!!input$group_variable]])
      }

      if (input$fill_variable != "") {
        mapping$fill <- rlang::expr(.data[[!!input$fill_variable]])
      }

      mapping
    })

    build_bar_plot <- function() {
      col_args <- list(
        linetype = input$linetype,
        position = input$position,
        linewidth = input$border_size,
        width = input$border_width,
        alpha = input$alpha,
        color = input$border_color
      )

      if (input$fill_variable == "") {
        col_args$fill <- input$fill_color
      }

      p <- ggplot(df(), bar_mapping()) +
        do.call(geom_col, col_args)

      p |>
        add_standard_plot_labels(input) |>
        apply_fill_scales(input) |>
        apply_plot_limits(input)
    }

    dot_plot_reac <- eventReactive(input$Plot,{
      p <- build_bar_plot()
      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "Bar_Plot")
    
  })
  
}
