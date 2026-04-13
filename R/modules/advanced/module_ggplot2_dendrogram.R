ggplot2_dendrogram_Server <- function(id){
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

      sync_column_choices(
        session,
        df(),
        "label_column",
        selected_map = list(
          label_column = bgc_pick_column(input$label_column, default_metadata[1])
        )
      )
    }, ignoreNULL = FALSE)

    hclust_fit <- reactive({
      metadata_cols <- input$metadata_columns
      if (is.null(metadata_cols)) metadata_cols <- character()

      analysis <- bgc_analysis_input(df(), metadata_cols)
      mat <- as.matrix(analysis$feature_data)

      label_col <- input$label_column
      if (!is.null(label_col) && nzchar(label_col) && label_col %in% names(df())) {
        labels_vec <- as.character(df()[[label_col]])
      } else {
        labels_vec <- rownames(df())
        if (is.null(labels_vec)) labels_vec <- as.character(seq_len(nrow(mat)))
      }

      if (input$scale_data == "Yes") {
        mat <- scale(mat)
      }

      if (input$cluster_on == "columns") {
        target <- t(mat)
        rownames(target) <- analysis$feature_columns
      } else {
        target <- mat
        rownames(target) <- labels_vec
      }

      d <- dist(target, method = input$dist_method)
      hc <- hclust(d, method = input$hclust_method)
      list(hc = hc, labels = rownames(target))
    })

    build_dendrogram_plot <- function() {
      fit <- hclust_fit()
      hc <- fit$hc

      dendro <- ggdendro::dendro_data(as.dendrogram(hc), type = "rectangle")
      segments <- ggdendro::segment(dendro)
      labels_df <- ggdendro::label(dendro)

      cluster_assignment <- NULL
      if (isTRUE(input$k_groups > 1)) {
        cluster_assignment <- cutree(hc, k = input$k_groups)
        labels_df$group <- factor(cluster_assignment[as.character(labels_df$label)])
      }

      p <- ggplot() +
        geom_segment(
          data = segments,
          aes(x = x, y = y, xend = xend, yend = yend),
          color = input$branch_color,
          linewidth = input$branch_width
        )

      if (!is.null(cluster_assignment)) {
        p <- p + geom_text(
          data = labels_df,
          aes(x = x, y = y, label = label, color = group),
          hjust = 1,
          angle = 0,
          size = input$label_size / 4,
          nudge_y = -max(segments$y) * 0.01
        )
        if (!is.null(input$discrete_color_choose) && input$discrete_color_choose != "") {
          p <- p + get(input$discrete_color_choose)()
        }
      } else {
        p <- p + geom_text(
          data = labels_df,
          aes(x = x, y = y, label = label),
          hjust = 1,
          color = input$label_color,
          size = input$label_size / 4,
          nudge_y = -max(segments$y) * 0.01
        )
      }

      p <- p +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          title = input$plot_title,
          subtitle = input$plot_subtitle,
          color = NULL
        ) +
        get(input$theme_choose)() +
        theme(
          text = element_text(size = input$label_size),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          panel.grid = element_blank()
        )

      p <- switch(
        input$orientation,
        right = p + coord_flip() + scale_y_reverse(),
        left  = p + coord_flip(),
        bottom = p + scale_y_reverse(),
        p
      )

      p
    }

    dendro_reac <- eventReactive(input$Plot, {
      p <- build_dendrogram_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, dendro_reac, vals, "Dendrogram_Plot")
  })
}
