ggplot2_pieplot_Server <- function(id){
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
    
    # data trans
    df2 <- reactive({
      df() %>%
        dplyr::arrange(desc(group)) %>%
        dplyr::mutate(prop = value / sum(value) * 100) %>%
        dplyr::mutate(percent = paste0(round(prop, 2), "%")) %>%
        dplyr::mutate(ypos = cumsum(prop) - 0.5 * prop)
    })
    
    # Set Plot Theme
    # Plot_theme <- reactive({input$theme_choose})
    # Set Discrete fill
    Plot_Discrete_fill <- reactive({input$discrete_fill_choose})
    # Set Continues fill
    # Plot_Continues_fill <- reactive({input$continuous_fill_choose})
    
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
    
    
    # ggplot(data = data2, aes(x = 0, y = prop, fill = group)) +
    #   geom_bar(stat = "identity", width = 2, color = "white",
    #            size = 1) +
    #   geom_text_repel(aes(x = 1, y = ypos, label = group),
    #                   size = 5,
    #                   color = "red",
    #                   segment.size = 1,
    #                   segment.angle = 20,
    #                   segment.color = "red",
    #                   nudge_x = 0.25,
    #                   nudge_y = 0) +
    #   coord_polar("y", start = 0) +
    #   theme_void()
    
    # dot plot
    dot_plot_reac <- eventReactive(input$Plot,{
      
      if (input$add_label == "Yes" & input$add_bar_label == "No") {
        p <- ggplot(data = df2(), 
                    aes(x = 0, 
                        y = prop, 
                        fill = group)) + 
          geom_bar(
            stat = "identity", 
            width = input$pie_width,
            linewidth = input$pie_line_width,
            color = input$pie_border_color,
            alpha = input$pie_alpha
            ) + 
          geom_text(aes(x = input$lable_position, 
                        y = ypos, 
                        label = str_c(group, " (", percent, ")")),
                    color = input$label_color,
                    size = input$lable_size,) + 
          coord_polar("y", start = 0) +
          theme_void()
      }else if (input$add_label == "No" & input$add_bar_label == "No") {
        p <- ggplot(data = df2(), 
                    aes(x = 0, 
                        y = prop, 
                        fill = group)) + 
          geom_bar(
            stat = "identity", 
            width = input$pie_width, 
            linewidth = input$pie_line_width,
            color = input$pie_border_color,
            alpha = input$pie_alpha
          ) + 
          coord_polar("y", start = 0) +
          theme_void()
      }else if (input$add_label == "Yes" & input$add_bar_label == "Yes") {
        p <- ggplot(data = df2(), 
                    aes(x = 0, 
                        y = prop, 
                        fill = group)) + 
          geom_bar(
            stat = "identity", 
            width = input$pie_width,
            linewidth = input$pie_line_width,
            color = input$pie_border_color,
            alpha = input$pie_alpha
          ) + 
          geom_text_repel(aes(x = input$add_lable_position, 
                              y = ypos, 
                              label = str_c(group, " (", percent, ")")),
                          size = input$add_lable_size,
                          color = input$add_lable_color,
                          segment.size = input$add_bar_size,
                          segment.angle = input$add_bar_angle,
                          segment.color = input$add_lable_color,
                          nudge_x = input$add_bar_x,
                          nudge_y = input$add_bar_y) +
          coord_polar("y", start = 0) +
          theme_void()
      }else if (input$add_label == "No" & input$add_bar_label == "Yes") {
        p <- ggplot(data = df2(), 
                    aes(x = 0, 
                        y = prop, 
                        fill = group)) + 
          geom_bar(
            stat = "identity", 
            width = input$pie_width,
            linewidth = input$pie_line_width,
            color = input$pie_border_color,
            alpha = input$pie_alpha
          ) + 
          geom_text_repel(aes(x = input$add_lable_position, 
                              y = ypos, 
                              label = str_c(group, " (", percent, ")")),
                          size = input$add_lable_size,
                          color = input$add_lable_color,
                          segment.size = input$add_bar_size,
                          segment.angle = input$add_bar_angle,
                          segment.color = input$add_lable_color,
                          nudge_x = input$add_bar_x,
                          nudge_y = input$add_bar_y) +
          coord_polar("y", start = 0) +
          theme_void()
      }
    
      if (input$discrete_fill_choose == "") {
        p
      }else{
        p <- p + get(Plot_Discrete_fill())()
      }
      

      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "Pie_Plot")

  })

}
