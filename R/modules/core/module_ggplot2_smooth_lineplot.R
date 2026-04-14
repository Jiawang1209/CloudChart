ggplot2_smooth_lineplot_Server <- function(id){
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
    # Set Continues fill
    Plot_Continues_fill <- reactive({input$continuous_fill_choose})
    
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
      
      if (input$group_variable != "") {
        if (input$color_variable != "") {
          if (input$add_point == "Yes") {
            if (input$linetype_variable != "") {
              p <- ggplot(df(),
                          aes(x = .data[[input$x_axis]],
                              y = .data[[input$y_axis]],
                              group = .data[[input$group_variable]],
                              color = .data[[input$color_variable]])) + 
                geom_xspline(aes(linetype = .data[[input$linetype_variable]]),
                             size = input$border_width,
                             spline_shape = input$spline_shape) + 
                geom_point(aes(fill = .data[[input$color_variable]]),
                           shape = 21,
                           size = input$point_size,
                           stroke = input$point_width) + 
                labs(x = input$x_axis_Title,
                     y = input$y_axis_Title,
                     title = input$plot_title,
                     subtitle = input$plot_subtitle) +
                get(Plot_theme())() + 
                theme(text = element_text(size = input$label_size))
            }else if (input$linetype_variable == "") {
              p <- ggplot(df(),
                          aes(x = .data[[input$x_axis]],
                              y = .data[[input$y_axis]],
                              group = .data[[input$group_variable]],
                              color = .data[[input$color_variable]])) + 
                geom_xspline(
                  size = input$border_width,
                  spline_shape = input$spline_shape
                  ) + 
                geom_point(aes(fill = .data[[input$color_variable]]),
                           shape = 21,
                           size = input$point_size,
                           stroke = input$point_width) + 
                labs(x = input$x_axis_Title,
                     y = input$y_axis_Title,
                     title = input$plot_title,
                     subtitle = input$plot_subtitle) +
                get(Plot_theme())() + 
                theme(text = element_text(size = input$label_size))
            }
            
          }else if (input$add_point == "No") {
            if (input$linetype_variable != "") {
              p <- ggplot(df(),
                          aes(x = .data[[input$x_axis]],
                              y = .data[[input$y_axis]],
                              group = .data[[input$group_variable]],
                              color = .data[[input$color_variable]])) + 
                geom_xspline(aes(linetype = .data[[input$linetype_variable]]),
                             size = input$border_width,
                             spline_shape = input$spline_shape) + 
                # geom_point(aes(fill = .data[[input$color_variable]]),
                #            shape = 21,
                #            size = input$point_size,
                #            stroke = input$point_width) + 
                labs(x = input$x_axis_Title,
                     y = input$y_axis_Title,
                     title = input$plot_title,
                     subtitle = input$plot_subtitle) +
                get(Plot_theme())() + 
                theme(text = element_text(size = input$label_size))
            }else if (input$linetype_variable == "") {
              p <- ggplot(df(),
                          aes(x = .data[[input$x_axis]],
                              y = .data[[input$y_axis]],
                              group = .data[[input$group_variable]],
                              color = .data[[input$color_variable]])) + 
                geom_xspline(
                  size = input$border_width,
                  spline_shape = input$spline_shape
                  ) + 
                # geom_point(aes(fill = .data[[input$color_variable]]),
                #            shape = 21,
                #            size = input$point_size,
                #            stroke = input$point_width) + 
                labs(x = input$x_axis_Title,
                     y = input$y_axis_Title,
                     title = input$plot_title,
                     subtitle = input$plot_subtitle) +
                get(Plot_theme())() + 
                theme(text = element_text(size = input$label_size))
            }
          }
        }else if (input$color_variable == "") {
          if (input$add_point == "Yes") {
            if (input$linetype_variable != "") {
              p <- ggplot(df(),
                          aes(x = .data[[input$x_axis]],
                              y = .data[[input$y_axis]],
                              group = .data[[input$group_variable]])) + 
                geom_xspline(
                  aes(linetype = .data[[input$linetype_variable]]),
                  size = input$border_width,
                  color = input$border_color,
                  spline_shape = input$spline_shape) + 
                geom_point(
                  shape = 21,
                  size = input$point_size,
                  color = input$border_color,
                  fill = input$fill_color,
                  stroke = input$point_width) + 
                labs(x = input$x_axis_Title,
                     y = input$y_axis_Title,
                     title = input$plot_title,
                     subtitle = input$plot_subtitle) +
                get(Plot_theme())() + 
                theme(text = element_text(size = input$label_size))
            }else if (input$linetype_variable == "") {
              p <- ggplot(df(),
                          aes(x = .data[[input$x_axis]],
                              y = .data[[input$y_axis]],
                              group = .data[[input$group_variable]])) + 
                geom_xspline(
                  size = input$border_width,
                  color = input$border_color,
                  spline_shape = input$spline_shape) + 
                geom_point(
                  shape = 21,
                  size = input$point_size,
                  color = input$border_color,
                  fill = input$fill_color,
                  stroke = input$point_width) + 
                labs(x = input$x_axis_Title,
                     y = input$y_axis_Title,
                     title = input$plot_title,
                     subtitle = input$plot_subtitle) +
                get(Plot_theme())() + 
                theme(text = element_text(size = input$label_size))
            }
            
          }else if (input$add_point == "No") {
            if (input$linetype_variable != "") {
              p <- ggplot(df(),
                          aes(x = .data[[input$x_axis]],
                              y = .data[[input$y_axis]],
                              group = .data[[input$group_variable]])) + 
                geom_xspline(
                  aes(linetype = .data[[input$linetype_variable]]),
                  size = input$border_width,
                  color = input$border_color,
                  spline_shape = input$spline_shape
                  ) + 
                labs(x = input$x_axis_Title,
                     y = input$y_axis_Title,
                     title = input$plot_title,
                     subtitle = input$plot_subtitle) +
                get(Plot_theme())() + 
                theme(text = element_text(size = input$label_size))
            }else if (input$linetype_variable == "") {
              p <- ggplot(df(),
                          aes(x = .data[[input$x_axis]],
                              y = .data[[input$y_axis]],
                              group = .data[[input$group_variable]])) + 
                geom_xspline(
                  size = input$border_width,
                  color = input$border_color,
                  spline_shape = input$spline_shape
                  ) + 
                labs(x = input$x_axis_Title,
                     y = input$y_axis_Title,
                     title = input$plot_title,
                     subtitle = input$plot_subtitle) +
                get(Plot_theme())() + 
                theme(text = element_text(size = input$label_size))
            }
          }
        }
      }else if (input$group_variable == "") {
        if (input$add_point == "Yes") {
          p <- ggplot(df(),
                      aes(x = .data[[input$x_axis]],
                          y = .data[[input$y_axis]])) + 
            geom_xspline(
              size = input$border_width,
              color = input$border_color,
              spline_shape = input$spline_shape
              ) + 
            geom_point(
              shape = 21,
              color = input$border_color,
              fill = input$fill_color,
              size = input$point_size,
              stroke = input$point_width) + 
            labs(x = input$x_axis_Title,
                 y = input$y_axis_Title,
                 title = input$plot_title,
                 subtitle = input$plot_subtitle) +
            get(Plot_theme())() + 
            theme(text = element_text(size = input$label_size))
        }else if (input$add_point == "No") {
          p <- ggplot(df(),
                      aes(x = .data[[input$x_axis]],
                          y = .data[[input$y_axis]])) + 
            geom_xspline(
              size = input$border_width,
              color = input$border_color,
              spline_shape = input$spline_shape
              ) + 
            # geom_point(
            #   shape = 21,
            #   color = input$border_color,
            #   fill = input$fill_color,
            #   size = input$point_size,
            #   stroke = input$point_width) + 
            labs(x = input$x_axis_Title,
                 y = input$y_axis_Title,
                 title = input$plot_title,
                 subtitle = input$plot_subtitle) +
            get(Plot_theme())() + 
            theme(text = element_text(size = input$label_size))
        }
      }
      
      
      if (input$discrete_fill_choose == "") {
        p
      }else{
        p <- p + get(Plot_Discrete_fill())()
      }
      
      if (input$continuous_fill_choose == "" ) {
        p
      }else{
        p <- p + scale_fill_material(Plot_Continues_fill())
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
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "Line_Plot")

  })

}
