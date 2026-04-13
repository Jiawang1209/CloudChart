ggplot2_radar_plot_Server <- function(id){
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
      
      p <- ggradar(df(), 
                   values.radar = c(input$grid.min, input$grid.mid, input$grid.max),
                   # aes(group = X.group.),
                   # fill = '#df65b0',
                   grid.min = as.numeric(input$grid.min),
                   grid.mid = as.numeric(input$grid.mid),
                   grid.max = as.numeric(input$grid.max),
                   group.line.width = input$line_width,
                   group.point.size = input$point_size,
                   group.colours = input$group_color,
                   grid.label.size = input$grid_label_size,
                   axis.label.size = input$axis_label_size,
                   background.circle.colour = input$background_color,
                   gridline.mid.colour = input$gridline_mid_color)
      
      print(p)
      vals$p <- p
    })
    
    output$plotOutput <- renderPlot({
      dot_plot_reac()
    })
    
    output$Download <- downloadHandler(
      filename = function(){paste0("Radar_Plot_", Sys.Date(),".pdf")},
      content = function(file){
        pdf(file = file, height = input$Height, width = input$Width)
        print(vals$p)
        dev.off()
      }
    )
    
    output$interactive_plot <- renderPlotly({
      ggplotly(dot_plot_reac())
    })
    
  })
  
}
