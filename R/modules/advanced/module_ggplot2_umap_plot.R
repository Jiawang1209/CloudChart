ggplot2_umap_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    
    df <- uploaded_table_reactive(input, row_names = TRUE)

    observeEvent(df(), {
      default_metadata <- bgc_default_metadata_columns(df())
      current_metadata <- input$metadata_columns
      if (is.null(current_metadata)) {
        current_metadata <- character()
      }
      sync_multi_column_choices(
        session,
        df(),
        "metadata_columns",
        selected = intersect(current_metadata, names(df()))
      )

      if (length(current_metadata) == 0 && length(default_metadata) > 0) {
        updateSelectizeInput(
          session = session,
          inputId = "metadata_columns",
          choices = names(df()),
          selected = default_metadata,
          server = TRUE
        )
      }
    }, ignoreNULL = FALSE)

    analysis_input <- reactive({
      metadata_columns <- input$metadata_columns
      if (is.null(metadata_columns)) {
        metadata_columns <- character()
      }
      if (length(metadata_columns) == 0) {
        metadata_columns <- bgc_default_metadata_columns(df())
      }
      bgc_analysis_input(df(), metadata_columns)
    })
    
    # UMAP
    UMAP_out <- reactive({
      fd <- analysis_input()$feature_data
      validate_matrix_input(fd, min_feature_columns = 2)
      bgc_cached_compute(
        key = list("umap::umap", fd, seed = 2023),
        compute = function() {
          set.seed(2023)
          umap::umap(fd)
        }
      )
    })
    
    UMAP_table.pca <- reactive({
      stats::setNames(as.data.frame(UMAP_out()$layout), c("UMAP1", "UMAP2"))
    })
    
    UMAP_out_2 <- reactive({
      tmp <- UMAP_table.pca()
      metadata_df <- analysis_input()$metadata_data
      cbind(tmp, metadata_df)
    })

    observeEvent(UMAP_out_2(), {
      umap_cols <- names(UMAP_out_2())
      discrete_cols <- bgc_discrete_columns(UMAP_out_2())

      sync_column_choices(
        session,
        UMAP_out_2(),
        c("x_axis", "y_axis", "fill_variable", "color_variable", "shape_variable"),
        selected_map = list(
          x_axis = bgc_pick_column(input$x_axis, bgc_first_match("UMAP1", umap_cols)),
          y_axis = bgc_pick_column(input$y_axis, bgc_first_match("UMAP2", umap_cols)),
          fill_variable = bgc_pick_column(input$fill_variable, discrete_cols[1]),
          color_variable = bgc_pick_column(input$color_variable, discrete_cols[1]),
          shape_variable = bgc_pick_column(input$shape_variable, discrete_cols[2], discrete_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    umap_mapping <- reactive({
      validate_required_columns(
        UMAP_out_2(),
        c(input$x_axis, input$y_axis, input$fill_variable, input$color_variable, input$shape_variable),
        data_label = "UMAP result"
      )
      validate_shape_range(input)

      mapping <- aes(
        x = .data[[input$x_axis]],
        y = .data[[input$y_axis]]
      )

      if (nzchar(input$fill_variable)) {
        mapping$fill <- rlang::expr(.data[[!!input$fill_variable]])
      }

      if (nzchar(input$color_variable)) {
        mapping$color <- rlang::expr(.data[[!!input$color_variable]])
      }

      if (input$shape_variable != "") {
        mapping$shape <- rlang::expr(.data[[!!input$shape_variable]])
      }

      mapping
    })

    build_umap_plot <- function() {
      point_args <- list(
        mapping = umap_mapping(),
        size = input$point_size,
        alpha = input$point_alpha
      )

      if (input$shape_variable == "") {
        point_args$shape <- 21
      }

      p <- ggplot(UMAP_out_2()) +
        do.call(geom_point, point_args)

      if (input$add_ellipse == "Yes" && nzchar(input$color_variable)) {
        p <- p + stat_ellipse(aes(color = .data[[input$color_variable]]), size = input$ellipse_size)
      }

      if (input$shape_variable != "") {
        p <- p + scale_shape_manual(values = input$shape_value[1]:input$shape_value[2])
      }

      p |>
        add_standard_plot_labels(input, x_label = "UMAP1", y_label = "UMAP2") |>
        apply_fill_scales(input) |>
        apply_color_scales(input) |>
        apply_plot_limits(input)
    }

    dot_plot_reac <- eventReactive(input$Plot,{
      p <- build_umap_plot()
      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "UMAP_Plot")
    
  })
  
}
