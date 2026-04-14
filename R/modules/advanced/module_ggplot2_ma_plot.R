ggplot2_ma_plot_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      sync_column_choices(
        session, df(),
        c("mean_var","logfc_var","padj_var","label_var"),
        selected_map = list(
          mean_var  = bgc_pick_column(input$mean_var,
                                      bgc_first_match(c("baseMean","mean","Mean","A"), names(df())),
                                      numeric_cols[1]),
          logfc_var = bgc_pick_column(input$logfc_var,
                                      bgc_first_match(c("log2FoldChange","logFC","M"), names(df())),
                                      numeric_cols[2], numeric_cols[1]),
          padj_var  = bgc_pick_column(input$padj_var,
                                      bgc_first_match(c("padj","FDR","adj.P.Val","p.adjust"), names(df()))),
          label_var = bgc_pick_column(input$label_var,
                                      bgc_first_match(c("gene","Gene","symbol","Symbol","ID"), names(df())))
        )
      )
    }, ignoreNULL = FALSE)

    ma_data <- reactive({
      validate_required_columns(df(), c(input$mean_var, input$logfc_var))
      validate_numeric_columns(df(), c(input$mean_var, input$logfc_var))

      data <- df()
      data$mean_val <- as.numeric(data[[input$mean_var]])
      data$lfc <- as.numeric(data[[input$logfc_var]])
      data <- data[!is.na(data$mean_val) & !is.na(data$lfc) & data$mean_val > 0, ]

      validate(need(nrow(data) > 0, "No usable rows after filtering missing/zero mean values."))

      has_padj <- nzchar(input$padj_var %||% "") && input$padj_var %in% names(data)
      if (has_padj) {
        data$padj <- as.numeric(data[[input$padj_var]])
        sig <- !is.na(data$padj) & data$padj <= input$padj_cut & abs(data$lfc) >= input$lfc_cut
        data$status <- ifelse(sig & data$lfc > 0, "Up",
                       ifelse(sig & data$lfc < 0, "Down", "NS"))
      } else {
        sig <- abs(data$lfc) >= input$lfc_cut
        data$status <- ifelse(sig & data$lfc > 0, "Up",
                       ifelse(sig & data$lfc < 0, "Down", "NS"))
      }

      data$status <- factor(data$status, levels = c("Up","NS","Down"))
      data
    })

    build_ma <- function(){
      data <- ma_data()
      colors <- c(Up = input$up_color, NS = input$ns_color, Down = input$down_color)

      p <- ggplot(data, aes(x = mean_val, y = lfc, color = status)) +
        geom_point(size = input$point_size, alpha = 0.75) +
        geom_hline(yintercept = 0, color = "#444", linetype = "dashed") +
        scale_color_manual(values = colors)

      if (input$lfc_cut > 0) {
        p <- p + geom_hline(yintercept = c(-input$lfc_cut, input$lfc_cut),
                            color = "#888", linetype = "dotted")
      }

      if (identical(input$log_x, "yes")) {
        p <- p + scale_x_log10()
      }

      if (nzchar(input$label_var %||% "") && input$label_var %in% names(data)) {
        sig_data <- data[data$status != "NS", ]
        if (nrow(sig_data) > 0) {
          top_n <- min(20, nrow(sig_data))
          sig_data <- sig_data[order(abs(sig_data$lfc), decreasing = TRUE), ][seq_len(top_n), ]
          p <- p + geom_text(
            data = sig_data,
            aes(label = .data[[input$label_var]]),
            vjust = -0.6,
            size = input$label_size / 4,
            show.legend = FALSE
          )
        }
      }

      p +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          title = input$plot_title,
          subtitle = input$plot_subtitle,
          color = NULL
        ) +
        get(input$theme_choose)() +
        theme(text = element_text(size = input$label_size))
    }

    ma_reac <- eventReactive(input$Plot, {
      p <- build_ma()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, ma_reac, vals, "MA_Plot")
  })
}
