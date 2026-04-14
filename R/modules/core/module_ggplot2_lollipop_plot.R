ggplot2_lollipop_plot_Server <- function(id){
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
      
      if (input$color_variable != "") {
        if (input$coord_flip == "No") {
          p <- ggplot(df(), aes(x = .data[[input$x_axis]],
                                y = .data[[input$y_axis]])) +
            geom_segment(aes(x = .data[[input$x_axis]],
                             xend = .data[[input$x_axis]],
                             y = 0,
                             yend = .data[[input$y_axis]]),
                         linewidth = input$border_width,
                         linetype = input$line_type,
                         color = input$line_color) + 
            geom_point(aes(color = .data[[input$color_variable]]),
                       size = input$point_size,
                       alpha = input$point_alpha) + 
            labs(x = input$x_axis_Title,
                 y = input$y_axis_Title,
                 title = input$plot_title,
                 subtitle = input$plot_subtitle) +
            get(Plot_theme())() +
            theme(text = element_text(size = input$label_size))
          
        }else if (input$coord_flip == "Yes") {
          p <- ggplot(df(), aes(x = .data[[input$x_axis]],
                                y = .data[[input$y_axis]])) +
            geom_segment(aes(x = .data[[input$x_axis]],
                             xend = .data[[input$x_axis]],
                             y = 0,
                             yend = .data[[input$y_axis]]),
                         linewidth = input$border_width,
                         linetype = input$line_type,
                         color = input$line_color) + 
            geom_point(aes(color = .data[[input$color_variable]]),
                       size = input$point_size,
                       alpha = input$point_alpha) + 
            labs(x = input$x_axis_Title,
                 y = input$y_axis_Title,
                 title = input$plot_title,
                 subtitle = input$plot_subtitle) +
            get(Plot_theme())() +
            theme(text = element_text(size = input$label_size)) + 
            coord_flip()
        }
      }else if (input$color_variable == "") {
        if (input$coord_flip == "No") {
          p <- ggplot(df(), aes(x = .data[[input$x_axis]],
                                y = .data[[input$y_axis]])) +
            geom_segment(aes(x = .data[[input$x_axis]],
                             xend = .data[[input$x_axis]],
                             y = 0,
                             yend = .data[[input$y_axis]]),
                         linewidth = input$border_width,
                         linetype = input$line_type,
                         color = input$line_color) + 
            geom_point(color = input$point_color,
                       size = input$point_size,
                       alpha = input$point_alpha) + 
            labs(x = input$x_axis_Title,
                 y = input$y_axis_Title,
                 title = input$plot_title,
                 subtitle = input$plot_subtitle) +
            get(Plot_theme())() +
            theme(text = element_text(size = input$label_size))
          
        }else if (input$coord_flip == "Yes") {
          p <- ggplot(df(), aes(x = .data[[input$x_axis]],
                                y = .data[[input$y_axis]])) +
            geom_segment(aes(x = .data[[input$x_axis]],
                             xend = .data[[input$x_axis]],
                             y = 0,
                             yend = .data[[input$y_axis]]),
                         linewidth = input$border_width,
                         linetype = input$line_type,
                         color = input$line_color) + 
            geom_point(color = input$point_color,
                       size = input$point_size,
                       alpha = input$point_alpha) + 
            labs(x = input$x_axis_Title,
                 y = input$y_axis_Title,
                 title = input$plot_title,
                 subtitle = input$plot_subtitle) +
            get(Plot_theme())() +
            theme(text = element_text(size = input$label_size)) + 
            coord_flip()
        }
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
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "lollipop_Plot")

  })

}
