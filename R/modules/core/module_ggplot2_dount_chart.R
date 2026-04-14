ggplot2_dountplot_Server <- function(id){
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
        dplyr::mutate(fraction = value / sum(value)) %>%
        dplyr::mutate(ymax = cumsum(fraction)) %>%
        dplyr::mutate(ymin = lag(ymax, default = 0)) %>%
        dplyr::mutate(labelPosition = (ymax + ymin)/2) %>%
        dplyr::mutate(label = str_c(group,
                                    "\n value:",
                                    value)) %>%
        dplyr::mutate(percentage = str_c(group,
                                    "\n value:",
                                    value,
                                    "\n percentage:",
                                    round(fraction, 2) * 100,
                                    "%"))
    })
    
    # Set Plot Theme
    # Set Discrete fill
    Plot_Discrete_fill <- reactive({input$discrete_fill_choose})
    # Set Discrete color
    Plot_Discrete_color <- reactive({input$discrete_color_choose})
    
    # dot plot
    dot_plot_reac <- eventReactive(input$Plot,{
      
      if (input$add_label == "Yes" & input$add_percentage == "No") {
        p <- ggplot(data = df2(), 
                    aes(xmin = input$pie_width[1], 
                        xmax = input$pie_width[2],
                        ymin = ymin, 
                        ymax = ymax,
                        fill = group)) + 
          geom_rect(linewidth = input$pie_line_width,
                    alpha = input$pie_alpha,
                    color = input$pie_border_color) + 
          geom_text(
            x = input$lable_position,
            aes(y = labelPosition, label = label),
            color = input$label_color,
            size = input$lable_size) + 
          coord_polar(theta = "y") +
          xlim(c(input$pie_range[1], input$pie_range[2])) + 
          theme_void() + 
          theme(legend.position = "none")
      }else if (input$add_label == "No" & input$add_percentage == "No") {
        p <- ggplot(data = df2(), 
                    aes(xmin = input$pie_width[1], 
                        xmax = input$pie_width[2],
                        ymin = ymin, 
                        ymax = ymax,
                        fill = group)) + 
          geom_rect(linewidth = input$pie_line_width,
                    alpha = input$pie_alpha,
                    color = input$pie_border_color) + 
          # geom_label(
          #   x = input$lable_position,
          #   aes(y = labelPosition, label = label),
          #   color = input$label_color,
          #   size = input$lable_size) + 
          coord_polar(theta = "y") +
          xlim(c(input$pie_range[1], input$pie_range[2])) + 
          theme_void() + 
          theme(legend.position = "none")
      }else if (input$add_label == "Yes" & input$add_percentage == "Yes") {
        p <- ggplot(data = df2(), 
                    aes(xmin = input$pie_width[1], 
                        xmax = input$pie_width[2],
                        ymin = ymin, 
                        ymax = ymax,
                        fill = group)) + 
          geom_rect(linewidth = input$pie_line_width,
                    alpha = input$pie_alpha,
                    color = input$pie_border_color) + 
          geom_text(
            x = input$lable_position,
            aes(y = labelPosition,
                label = percentage),
            color = input$add_lable_color,
            size = input$lable_size) + 
          coord_polar(theta = "y") +
          xlim(c(input$pie_range[1], input$pie_range[2])) + 
          theme_void() + 
          theme(legend.position = "none")
      }else if (input$add_label == "No" & input$add_percentage == "Yes") {
        p <- ggplot(data = df2(), 
                    aes(xmin = input$pie_width[1], 
                        xmax = input$pie_width[2],
                        ymin = ymin, 
                        ymax = ymax,
                        fill = group)) + 
          geom_rect(linewidth = input$pie_line_width,
                    alpha = input$pie_alpha,
                    color = input$pie_border_color) + 
          geom_text(
            x = input$lable_position,
            aes(y = labelPosition, 
                label = percentage),
            color = input$add_lable_color,
            size = input$lable_size) + 
          coord_polar(theta = "y") +
          xlim(c(input$pie_range[1], input$pie_range[2])) + 
          theme_void() + 
          theme(legend.position = "none")
      }
      
      if (input$discrete_fill_choose == "") {
        p
      }else{
        p <- p + get(Plot_Discrete_fill())()
      }
      
      
      print(p)
      vals$p <- p
    })
    
    bind_plot_outputs(output, input, dot_plot_reac, vals, "Dount_Plot")

  })

}
