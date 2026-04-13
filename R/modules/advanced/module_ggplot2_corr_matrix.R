ggplot2_corr_matrix_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      default_metadata <- bgc_default_metadata_columns(df())
      current_metadata <- input$metadata_columns
      if (is.null(current_metadata)) current_metadata <- character()

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

    corr_data <- reactive({
      metadata_cols <- input$metadata_columns
      if (is.null(metadata_cols)) metadata_cols <- character()

      analysis <- bgc_analysis_input(df(), metadata_cols)
      mat <- as.matrix(analysis$feature_data)
      cor_mat <- cor(mat, method = input$cor_method, use = "pairwise.complete.obs")

      if (input$reorder_method == "hclust" && nrow(cor_mat) > 1) {
        ord <- hclust(as.dist(1 - abs(cor_mat)))$order
        cor_mat <- cor_mat[ord, ord]
      }

      if (input$matrix_shape == "upper") {
        cor_mat[lower.tri(cor_mat)] <- NA
      } else if (input$matrix_shape == "lower") {
        cor_mat[upper.tri(cor_mat)] <- NA
      }

      var_levels <- rownames(cor_mat)
      long <- as.data.frame(as.table(cor_mat), stringsAsFactors = FALSE)
      names(long) <- c("Var1", "Var2", "Correlation")
      long <- long[!is.na(long$Correlation), , drop = FALSE]
      long$Var1 <- factor(long$Var1, levels = var_levels)
      long$Var2 <- factor(long$Var2, levels = rev(var_levels))
      long
    })

    build_corr_matrix <- function() {
      data <- corr_data()

      p <- ggplot(data, aes(x = Var1, y = Var2, fill = Correlation)) +
        geom_tile(color = input$tile_border)

      if (input$show_label == "Yes") {
        p <- p + geom_text(
          aes(label = round(Correlation, input$label_digits)),
          color = input$label_color,
          size = input$label_size / 4
        )
      }

      p <- p + scale_fill_gradient2(
        low = input$low_color,
        mid = input$mid_color,
        high = input$high_color,
        midpoint = 0,
        limits = c(-1, 1)
      )

      p +
        labs(
          x = NULL,
          y = NULL,
          title = input$plot_title,
          subtitle = input$plot_subtitle,
          fill = "r"
        ) +
        get(input$theme_choose)() +
        theme(
          text = element_text(size = input$label_size),
          axis.text.x = element_text(angle = 45, hjust = 1)
        ) +
        coord_fixed()
    }

    corr_reac <- eventReactive(input$Plot, {
      p <- build_corr_matrix()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, corr_reac, vals, "Correlation_Matrix")
  })
}
