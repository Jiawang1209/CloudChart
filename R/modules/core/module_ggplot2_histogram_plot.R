ggplot2_histogram_plot_Server <- function(id){
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
      
      p <- ggplot(df()) + 
        geom_histogram(aes(x = value), 
                       bins = input$bins_width, 
                       fill = input$fill_color, 
                       color = input$line_color, 
                       alpha = input$alpha,
                       linewidth = input$line_width
                       ) + 
        labs(x = input$x_axis_Title,
             y = input$y_axis_Title,
             # title = input$plot_title,
             subtitle = input$plot_subtitle) +
        ggtitle(label = paste0("The bin is ", input$bins_width)) + 
        get(Plot_theme())() +
        theme(text = element_text(size = input$label_size))
      
      
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
