ggplot2_manhattan_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      numeric_cols <- bgc_numeric_columns(df())
      sync_column_choices(
        session, df(),
        c("chrom_var","pos_var","pvalue_var","snp_var"),
        selected_map = list(
          chrom_var  = bgc_pick_column(input$chrom_var,
                                       bgc_first_match(c("CHR","chr","chrom","Chromosome"), names(df()))),
          pos_var    = bgc_pick_column(input$pos_var,
                                       bgc_first_match(c("BP","POS","Position","bp"), names(df())),
                                       numeric_cols[1]),
          pvalue_var = bgc_pick_column(input$pvalue_var,
                                       bgc_first_match(c("P","p","pvalue","P.value"), names(df())),
                                       numeric_cols[2], numeric_cols[1]),
          snp_var    = bgc_pick_column(input$snp_var,
                                       bgc_first_match(c("SNP","snp","ID","rsid"), names(df())))
        )
      )
    }, ignoreNULL = FALSE)

    manhattan_data <- reactive({
      validate_required_columns(df(), c(input$chrom_var, input$pos_var, input$pvalue_var))
      validate_numeric_columns(df(), c(input$pos_var, input$pvalue_var))

      data <- df()
      data$chrom <- as.factor(data[[input$chrom_var]])
      data$pos <- as.numeric(data[[input$pos_var]])
      data$pvalue <- as.numeric(data[[input$pvalue_var]])
      data <- data[!is.na(data$pos) & !is.na(data$pvalue) & data$pvalue > 0, ]

      validate(need(nrow(data) > 0, "No usable rows after filtering missing/zero p-values."))

      data <- data[order(data$chrom, data$pos), ]
      offsets <- tapply(data$pos, data$chrom, max, na.rm = TRUE)
      offsets <- c(0, cumsum(as.numeric(offsets)))
      names(offsets) <- c(levels(data$chrom), "_end")

      data$cum_pos <- data$pos + offsets[as.character(data$chrom)]
      data$logp <- -log10(data$pvalue)

      centers <- tapply(data$cum_pos, data$chrom, function(v) (min(v) + max(v)) / 2)
      list(
        data = data,
        centers = centers,
        chroms = levels(data$chrom)
      )
    })

    build_manhattan <- function(){
      bundle <- manhattan_data()
      data <- bundle$data
      n_chr <- length(bundle$chroms)
      palette_vals <- rep(c(input$color_a, input$color_b), length.out = n_chr)
      names(palette_vals) <- bundle$chroms

      p <- ggplot(data, aes(x = cum_pos, y = logp, color = chrom)) +
        geom_point(size = input$point_size, alpha = 0.8) +
        scale_color_manual(values = palette_vals, guide = "none") +
        scale_x_continuous(breaks = bundle$centers, labels = names(bundle$centers))

      if (input$sig_threshold > 0) {
        p <- p + geom_hline(yintercept = -log10(input$sig_threshold),
                            color = "#c1121f", linetype = "dashed")
      }
      if (input$sug_threshold > 0) {
        p <- p + geom_hline(yintercept = -log10(input$sug_threshold),
                            color = "#1d3557", linetype = "dotted")
      }

      if (identical(input$highlight_sig, "yes") && nzchar(input$snp_var %||% "")) {
        sig_data <- data[data$pvalue <= input$sig_threshold, ]
        if (nrow(sig_data) > 0) {
          p <- p + geom_text(
            data = sig_data,
            aes(label = .data[[input$snp_var]]),
            vjust = -0.6,
            size = input$label_size / 4,
            color = "#c1121f"
          )
        }
      }

      p +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          title = input$plot_title,
          subtitle = input$plot_subtitle
        ) +
        get(input$theme_choose)() +
        theme(
          text = element_text(size = input$label_size),
          panel.grid.minor.x = element_blank()
        )
    }

    manhattan_reac <- eventReactive(input$Plot, {
      p <- build_manhattan()
      print(p)
      vals$p <- p
    })

    bind_plot_outputs(output, input, manhattan_reac, vals, "Manhattan_Plot")
  })
}
