ggplot2_density_plot_2_Server <- function(id){
  moduleServer(id, function(input, output, session){
    vals <- reactiveValues()
    
    # load file
    df <- eventReactive(input$submit_file,{
      req(input$file_upload)
      
      tryCatch({
        if(input$file_separator == "xlsx2") {
          readxl::read_xlsx(path = input$file_upload$datapath)
        }else{
          read.csv(
            file = input$file_upload$datapath,
            header = input$file_header,
            sep = input$file_separator,
            quote = input$file_quote,
            check.names = F
          )
        }
      })
    })
    
    # Set Plot Theme
    Plot_theme <- reactive({input$theme_choose})
    # Set Discrete fill
    Plot_Discrete_fill <- reactive({input$discrete_fill_choose})
    
    # ggplot(df(),
    #         aes(x = .data[[input$x_axis]],
    #             y = .data[[input$y_axis]])) + 
    #   geom_xspline() + 
    #   labs(x = input$x_axis_Title,
    #        y = input$y_axis_Title,
    #        title = input$plot_title,
    #        subtitle = input$plot_subtitle) + 
    #   get(Plot_theme())() + 
    #   theme(text = element_text(size = input$label_size))
    
    
    # dot plot
    dot_plot_reac <- eventReactive(input$Plot,{
      
      if (input$kind == "density") {
        p <- ggplot(df()) + 
          geom_density(aes(x = .data[[input$column1]], y = after_stat(density)), 
                       fill = input$variable1_color,
                       # bins = input$bins_width,
                       color = input$border_color,
                       linewidth = input$line_width,
                       linetype = input$line_type,
                       alpha = input$alpha) + 
          geom_label(aes(x = as.numeric(input$label_position_x), y = as.numeric(input$label_position_y)),
                     label = input$column1,
                     color = input$border_color,
                     size = input$label_size_2
                     ) +
          geom_density(aes(x = .data[[input$column2]], y = -1*after_stat(density)), 
                       fill = input$variable2_color,
                       # bins = input$bins_width,
                       color = input$border_color,
                       linewidth = input$line_width,
                       linetype = input$line_type,
                       alpha = input$alpha) + 
          geom_label(aes(x = as.numeric(input$label_position_x), y = -1*as.numeric(input$label_position_y)),
                     label = input$column2,
                     color = input$border_color,
                     size = input$label_size_2
                     ) +
          labs(x = input$x_axis_Title,
               y = input$y_axis_Title,
               title = input$plot_title,
               subtitle = input$plot_subtitle) +
          get(Plot_theme())() +
          theme(text = element_text(size = input$label_size))
      }else if (input$kind == "histogram") {
        p <- ggplot(df()) + 
          geom_histogram(aes(x = .data[[input$column1]], y = after_stat(density)), 
                       fill = input$variable1_color,
                       bins = input$bins_width,
                       color = input$border_color,
                       linewidth = input$line_width,
                       linetype = input$line_type,
                       alpha = input$alpha) + 
          geom_label(aes(x = as.numeric(input$label_position_x), y = as.numeric(input$label_position_y)),
                     label = input$column1,
                     color = input$border_color,
                     size = input$label_size_2
                     ) +
          geom_histogram(aes(x = .data[[input$column2]], y = -1*after_stat(density)), 
                       fill = input$variable2_color,
                       bins = input$bins_width,
                       color = input$border_color,
                       linewidth = input$line_width,
                       linetype = input$line_type,
                       alpha = input$alpha) + 
          geom_label(aes(x = as.numeric(input$label_position_x), y = -1*as.numeric(input$label_position_y)),
                     label = input$column2,
                     color = input$border_color,
                     size = input$label_size_2
                     ) +
          labs(x = input$x_axis_Title,
               y = input$y_axis_Title,
               title = input$plot_title,
               subtitle = input$plot_subtitle) +
          get(Plot_theme())() +
          theme(text = element_text(size = input$label_size))
      }
      
      
      if (input$discrete_fill_choose == "") {
        p
      }else{
        p <- p + get(Plot_Discrete_fill())()
      }
      
      
      # Set x limite
      if (!is.null(input$x_limite[1])) {
        p <- p + xlim(input$x_limite[1], input$x_limite[2])
      }
      
      # Set y limite
      if (!is.null(input$y_limite[1])) {
        p <- p + ylim(input$y_limite[1], input$y_limite[2])
      }
      
      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "Density_Plot")

  })

}
