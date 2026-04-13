ggplot2_volcano_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    
    df <- uploaded_table_reactive(input)

    observeEvent(df(), {
      sync_column_choices(
        session,
        df(),
        c("x_axis", "y_axis", "color_variable", "size_variable"),
        selected_map = list(
          x_axis = bgc_pick_column(input$x_axis, "log2FoldChange"),
          y_axis = bgc_pick_column(input$y_axis, "pvalue"),
          color_variable = bgc_pick_column(input$color_variable, "change"),
          size_variable = bgc_pick_column(input$size_variable, "pvalue")
        ),
        extra_choices = "change"
      )
    }, ignoreNULL = FALSE)
    
    # data trans
    df2 <- reactive({
      validate_required_columns(
        df(),
        c("log2FoldChange", "pvalue", input$x_axis, input$y_axis, input$color_variable, input$size_variable)
      )
      validate_numeric_columns(df(), c("log2FoldChange", "pvalue", input$x_axis, input$y_axis, input$size_variable))

      df() %>%
        dplyr::mutate(change = case_when(
          log2FoldChange > input$log2fold_change & pvalue < input$pvalue ~ "Up",
          log2FoldChange < -(input$log2fold_change) & pvalue < input$pvalue ~ "Down",
          .default = "Normal"
        ))
    })
    
    # statisc DEG numbers
    title_deg <- reactive({
      paste0("Cutoff for log2Foldchange is ", 
             input$log2fold_change,
             "\nThe number of Up gene is ",
             nrow(df2() %>% dplyr::filter(change == "Up")),
             "\nThe number of Down gene is ",
             nrow(df2() %>% dplyr::filter(change == "Down"))
             )
    })
    build_volcano_plot <- function() {
      p <- ggplot(
        df2(),
        aes(
          x = .data[[input$x_axis]],
          y = -log10(.data[[input$y_axis]])
        )
      ) +
        geom_point(
          aes(
            color = .data[[input$color_variable]],
            size = -log10(.data[[input$size_variable]])
          ),
          alpha = input$point_alpha
        ) +
        scale_color_manual(
          values = c(
            "Up" = input$up_color,
            "Normal" = input$normal_color,
            "Down" = input$down_color
          )
        ) +
        scale_size(range = c(input$sizechange[1], input$sizechange[2])) +
        geom_hline(
          yintercept = -log10(input$pvalue),
          linetype = input$hlinetype,
          color = input$hcolor
        ) +
        geom_vline(
          xintercept = c(-input$log2fold_change, input$log2fold_change),
          linetype = input$vlinetype,
          color = input$vcolor
        ) +
        labs(
          x = input$x_axis_Title,
          y = input$y_axis_Title,
          subtitle = input$plot_subtitle
        ) +
        ggtitle(title_deg()) +
        get(input$theme_choose)() +
        theme(
          text = element_text(size = input$label_size),
          plot.title = element_text(size = input$label_size, hjust = 0.5)
        )

      p |>
        apply_plot_limits(input)
    }

    dot_plot_reac <- eventReactive(input$Plot,{
      p <- build_volcano_plot()
      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "Volcano_Plot")
    
  })
  
}
