ggplot2_waffle_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      sync_column_choices(
        session, df(),
        c("category_var"),
        selected_map = list(
          category_var = bgc_pick_column(input$category_var, bgc_discrete_columns(df())[1])
        )
      )
    }, ignoreNULL = FALSE)

    waffle_data <- reactive({
      req(nzchar(input$category_var))
      validate_required_columns(df(), input$category_var)

      total <- input$grid_rows * input$grid_cols
      values <- df()[[input$category_var]]
      values <- values[!is.na(values)]

      validate(need(length(values) > 0, "Selected category column has no non-missing values."))

      tab <- table(values)
      props <- as.numeric(tab) / sum(tab)
      counts <- pmax(round(props * total), 0)

      delta <- total - sum(counts)
      if (delta != 0) {
        residual <- props * total - counts
        idx <- order(residual, decreasing = delta > 0)[seq_len(abs(delta))]
        counts[idx] <- counts[idx] + sign(delta)
      }

      labels <- rep(names(tab), counts)
      length(labels) <- total
      labels[is.na(labels)] <- names(tab)[1]

      grid <- expand.grid(x = seq_len(input$grid_cols), y = seq_len(input$grid_rows))
      grid$category <- factor(labels, levels = names(tab))
      grid
    })

    build_waffle <- function(){
      data <- waffle_data()
      pad <- input$tile_pad

      p <- ggplot(data, aes(x = x, y = y, fill = category)) +
        geom_tile(color = "white", linewidth = pad * 8, width = 1 - pad, height = 1 - pad) +
        coord_equal() +
        scale_y_reverse()

      p <- p |> apply_fill_scales(input)
      add_standard_plot_labels(p, input,
                               x_label = input$x_axis_Title,
                               y_label = input$y_axis_Title) +
        theme(
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          panel.grid = element_blank()
        )
    }

    waffle_reac <- eventReactive(input$Plot, {
      p <- build_waffle()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, waffle_reac, vals, "Waffle_Plot")
  })
}
