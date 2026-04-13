ggplot2_rda_Server <- function(id){
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
            row.names = 1,
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
    Plot_Discrete_color <- reactive({input$discrete_color_choose})
    
    # PCA 
    PCA_out <- reactive({
      PCA(df()[,-ncol(df())])
    })
    
    PCA_table.pca <- reactive({
      as.data.frame(PCA_out()$ind$coord[,1:2])
    })
    
    PCA_out_2 <- reactive({
      tmp <- PCA_table.pca()
      tmp$Sample <- rownames(tmp)
      tmp2 <- df()
      tmp2$Sample <- rownames(tmp2)
      merge(tmp,tmp2)
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
      
      if (input$add_ellipse == "No") {
        if (input$shape_variable == "") {
          p <- ggplot(PCA_out_2(),
                      aes(x = .data[[input$x_axis]],
                          y = .data[[input$y_axis]])) + 
            geom_point(shape = 21,
                       aes(fill = .data[[input$fill_variable]],
                           color = .data[[input$color_variable]]),
                       size = input$point_size,
                       alpha = input$point_alpha) + 
            labs(x = paste('PC1 (', paste0(round(as.numeric(PCA_out()$eig[1,2]), digits = 2), '%'), ')', sep = ''),
                 y = paste('PC2 (', paste0(round(as.numeric(PCA_out()$eig[2,2]), digits = 2), '%'), ')', sep = ''),
                 title = input$plot_title,
                 subtitle = input$plot_subtitle
            ) + 
            get(Plot_theme())() + 
            theme(text = element_text(size = input$label_size))
        }else if (input$shape_variable != "") {
          p <- ggplot(PCA_out_2(),
                      aes(x = .data[[input$x_axis]],
                          y = .data[[input$y_axis]])) + 
            geom_point(aes(fill = .data[[input$fill_variable]],
                           color = .data[[input$color_variable]],
                           shape = .data[[input$shape_variable]]),
                       size = input$point_size,
                       alpha = input$point_alpha) + 
            scale_shape_manual(values = input$shape_value[1]:input$shape_value[2]) +
            labs(x = paste('PC1 (', paste0(round(as.numeric(PCA_out()$eig[1,2]), digits = 2), '%'), ')', sep = ''),
                 y = paste('PC2 (', paste0(round(as.numeric(PCA_out()$eig[2,2]), digits = 2), '%'), ')', sep = ''),
                 title = input$plot_title,
                 subtitle = input$plot_subtitle
            ) + 
            get(Plot_theme())() + 
            theme(text = element_text(size = input$label_size))
        }
      }else if (input$add_ellipse == "Yes") {
        if (input$shape_variable == "") {
          p <- ggplot(PCA_out_2(),
                      aes(x = .data[[input$x_axis]],
                          y = .data[[input$y_axis]])) + 
            geom_point(aes(fill = .data[[input$fill_variable]],
                           color = .data[[input$color_variable]]),
                       size = input$point_size,
                       alpha = input$point_alpha) + 
            stat_ellipse(aes(color = .data[[input$color_variable]]),
                         size = input$ellipse_size) + 
            labs(x = paste('PC1 (', paste0(round(as.numeric(PCA_out()$eig[1,2]), digits = 2), '%'), ')', sep = ''),
                 y = paste('PC2 (', paste0(round(as.numeric(PCA_out()$eig[2,2]), digits = 2), '%'), ')', sep = ''),
                 title = input$plot_title,
                 subtitle = input$plot_subtitle
            ) + 
            get(Plot_theme())() + 
            theme(text = element_text(size = input$label_size))
        }else if (input$shape_variable != "") {
          p <- ggplot(PCA_out_2(),
                      aes(x = .data[[input$x_axis]],
                          y = .data[[input$y_axis]])) + 
            geom_point(aes(fill = .data[[input$fill_variable]],
                           color = .data[[input$color_variable]],
                           shape = .data[[input$shape_variable]]),
                       size = input$point_size,
                       alpha = input$point_alpha) + 
            stat_ellipse(aes(color = .data[[input$color_variable]]),
                         size = input$ellipse_size) + 
            scale_shape_manual(values = input$shape_value[1]:input$shape_value[2]) +
            labs(x = paste('PC1 (', paste0(round(as.numeric(PCA_out()$eig[1,2]), digits = 2), '%'), ')', sep = ''),
                 y = paste('PC2 (', paste0(round(as.numeric(PCA_out()$eig[2,2]), digits = 2), '%'), ')', sep = ''),
                 title = input$plot_title,
                 subtitle = input$plot_subtitle
            ) + 
            get(Plot_theme())() + 
            theme(text = element_text(size = input$label_size))
        }
      }
      
      if (input$discrete_fill_choose == "") {
        p
      }else{
        p <- p + get(Plot_Discrete_fill())()
      }
      
      if (input$discrete_color_choose == "" ) {
        p
      }else{
        p <- p + get(Plot_Discrete_color())()
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
    
    output$plotOutput <- renderPlot({
      dot_plot_reac()
    })
    
    output$Download <- downloadHandler(
      filename = function(){paste0("PCA_Plot_", Sys.Date(),".pdf")},
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
