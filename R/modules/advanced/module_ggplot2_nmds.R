ggplot2_nmds_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()

    df <- uploaded_table_reactive(input, row_names = TRUE)

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

    analysis_input <- reactive({
      metadata_columns <- input$metadata_columns
      if (is.null(metadata_columns)) metadata_columns <- character()
      if (length(metadata_columns) == 0) {
        metadata_columns <- bgc_default_metadata_columns(df())
      }
      bgc_analysis_input(df(), metadata_columns)
    })

    nmds_out <- reactive({
      ai <- analysis_input()
      validate_matrix_input(ai$feature_data, min_feature_columns = 2)

      mat <- as.matrix(ai$feature_data)
      if (input$distance %in% c("bray","jaccard") && any(mat < 0, na.rm = TRUE)) {
        validate(need(FALSE, paste0(input$distance, " distance requires non-negative values.")))
      }

      tryCatch(
        suppressWarnings(vegan::metaMDS(
          mat,
          distance = input$distance,
          k = input$k_dim,
          trymax = input$trymax,
          autotransform = FALSE,
          trace = 0
        )),
        error = function(e) {
          validate(need(FALSE, paste("metaMDS failed:", conditionMessage(e))))
        }
      )
    })

    nmds_table <- reactive({
      coords <- as.data.frame(vegan::scores(nmds_out(), display = "sites"))
      names(coords) <- paste0("NMDS", seq_len(ncol(coords)))
      coords$Sample <- rownames(coords)
      meta <- analysis_input()$metadata_data
      meta$Sample <- rownames(df())
      merge(coords, meta, by = "Sample", all.x = TRUE)
    })

    observeEvent(nmds_table(), {
      cols <- names(nmds_table())
      grouping_cols <- setdiff(bgc_discrete_columns(nmds_table()), "Sample")
      sync_column_choices(
        session,
        nmds_table(),
        c("color_var"),
        selected_map = list(
          color_var = bgc_pick_column(input$color_var, grouping_cols[1])
        )
      )
    }, ignoreNULL = FALSE)

    build_nmds_plot <- function(){
      data <- nmds_table()
      stress_val <- round(nmds_out()$stress, 4)

      mapping <- if (nzchar(input$color_var %||% "")) {
        aes(x = NMDS1, y = NMDS2, color = .data[[input$color_var]])
      } else {
        aes(x = NMDS1, y = NMDS2)
      }

      p <- ggplot(data, mapping) +
        geom_point(size = input$point_size, alpha = 0.85) +
        labs(
          subtitle = paste0(
            if (nzchar(input$plot_subtitle %||% "")) paste0(input$plot_subtitle, " | ") else "",
            "stress = ", stress_val
          )
        )

      add_standard_plot_labels(p, input,
                               x_label = input$x_axis_Title,
                               y_label = input$y_axis_Title) |>
        apply_color_scales(input) |>
        apply_plot_limits(input)
    }

    nmds_reac <- eventReactive(input$Plot, {
      p <- build_nmds_plot()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, nmds_reac, vals, "NMDS_Plot")
  })
}
