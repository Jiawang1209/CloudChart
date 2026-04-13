ggplot2_pca_Server <- function(id){
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
    
    # PCA 
    PCA_out <- reactive({
      validate_matrix_input(analysis_input()$feature_data, min_feature_columns = 2)
      FactoMineR::PCA(analysis_input()$feature_data, graph = FALSE)
    })
    
    PCA_table.pca <- reactive({
      as.data.frame(PCA_out()$ind$coord[,1:2])
    })
    
    PCA_out_2 <- reactive({
      tmp <- PCA_table.pca()
      tmp$Sample <- rownames(tmp)
      metadata_df <- analysis_input()$metadata_data
      metadata_df$Sample <- rownames(df())
      merge(tmp, metadata_df, by = "Sample", all.x = TRUE)
    })

    observeEvent(PCA_out_2(), {
      pca_cols <- names(PCA_out_2())
      discrete_cols <- bgc_discrete_columns(PCA_out_2())
      grouping_cols <- setdiff(discrete_cols, c("Sample"))

      sync_column_choices(
        session,
        PCA_out_2(),
        c("x_axis", "y_axis", "fill_variable", "color_variable", "shape_variable"),
        selected_map = list(
          x_axis = bgc_pick_column(input$x_axis, bgc_first_match(c("Dim.1", "PC1"), pca_cols)),
          y_axis = bgc_pick_column(input$y_axis, bgc_first_match(c("Dim.2", "PC2"), pca_cols)),
          fill_variable = bgc_pick_column(input$fill_variable, grouping_cols[1]),
          color_variable = bgc_pick_column(input$color_variable, grouping_cols[1]),
          shape_variable = bgc_pick_column(input$shape_variable, grouping_cols[2], grouping_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    pca_mapping <- reactive({
      validate_required_columns(
        PCA_out_2(),
        c(input$x_axis, input$y_axis, input$fill_variable, input$color_variable, input$shape_variable),
        data_label = "PCA result"
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

    build_pca_plot <- function() {
      point_args <- list(
        mapping = pca_mapping(),
        size = input$point_size,
        alpha = input$point_alpha
      )

      if (input$shape_variable == "") {
        point_args$shape <- 21
      }

      p <- ggplot(PCA_out_2()) +
        do.call(geom_point, point_args)

      if (input$add_ellipse == "Yes" && nzchar(input$color_variable)) {
        p <- p + stat_ellipse(aes(color = .data[[input$color_variable]]), size = input$ellipse_size)
      }

      if (input$shape_variable != "") {
        p <- p + scale_shape_manual(values = input$shape_value[1]:input$shape_value[2])
      }

      x_label <- paste("PC1 (", paste0(round(as.numeric(PCA_out()$eig[1, 2]), digits = 2), "%"), ")", sep = "")
      y_label <- paste("PC2 (", paste0(round(as.numeric(PCA_out()$eig[2, 2]), digits = 2), "%"), ")", sep = "")

      p |>
        add_standard_plot_labels(input, x_label = x_label, y_label = y_label) |>
        apply_fill_scales(input) |>
        apply_color_scales(input) |>
        apply_plot_limits(input)
    }

    dot_plot_reac <- eventReactive(input$Plot,{
      p <- build_pca_plot()
      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "PCA_Plot")
    
  })
  
}
