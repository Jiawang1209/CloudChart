# Legacy compatibility snapshot.
# Do not use this file as the active entrypoint.
# Current entrypoints:
# - app.R
# - ui.R + server.R

source("R/global.R")

# UI
ui <-  dashboardPage(
  
  #CDN
  bs4Dash::bs4DashHead(
    # Use CDN to load the jQuery library
    tags$script(src = "https://code.jquery.com/jquery-3.5.1.min.js"),

    # Use CDN to load the Bootstrap library
    tags$link(rel = "stylesheet", href = "https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css"),
    tags$script(src = "https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js")
  ),
  
  # header
  header = dashboardHeader(
    title = dashboardBrand(
      title = "BGCViewer",
      color = "lightblue",
      href = "http://www.iae.cas.cn/biogeochemistry/",
      image = "https://adminlte.io/themes/v3/dist/img/AdminLTELogo.png"
    )
  ),
  sidebar = dashboardSidebar(
    width = 120,
    # sidebarUserPanel(
    #   image = "https://adminlte.io/themes/v3/dist/img/AdminLTELogo.png",
    #   name = "Welcome Visual module!"
    # ),
    sidebarMenu(
      id = "sidebarmenu",
      
      # Home Page
      menuItem(text = "Home Page", tabName = "home_page", icon = icon("house")),
      
      # Introduction
      menuItem("Introduction", tabName = "introduction", icon = icon("question")),
      
      # Basic Plot
      menuItem(text = "Basic Plot", icon = icon("bar-chart"), startExpanded = FALSE,
               menuSubItem(text = "Dot Plot", tabName = "dot_plot", icon = icon("image")),
               menuSubItem(text = "Bubble Plot", tabName = "bubble_plot", icon = icon("image")),
               menuSubItem(text = "Bar Plot", tabName = "bar_plot", icon = icon("image")),
               menuSubItem(text = "Line Plot", tabName = "line_plot", icon = icon("image")),
               menuSubItem(text = "Smooth Line Plot", tabName = "smooth_line_plot", icon = icon("image")),
               menuSubItem(text = "Box Plot", tabName = "box_plot", icon = icon("image")),
               menuSubItem(text = "Violin Plot", tabName = "violin_plot", icon = icon("image")),
               menuSubItem(text = "Pie Plot", tabName = "pie_plot", icon = icon("image")),
               menuSubItem(text = "Dount Plot", tabName = "dount_plot", icon = icon("image")),
               menuSubItem(text = "Density Plot", tabName = "density_plot", icon = icon("image")),
               menuSubItem(text = "Histogram Plot", tabName = "histogram_plot", icon = icon("image")),
               menuSubItem(text = "Density and  Histogram", tabName = "density_plot2", icon = icon("image")),
               menuSubItem(text = "Ridgeline Plot", tabName = "ridgeline_plot", icon = icon("image")),
               menuSubItem(text = "Radar Plot", tabName = "radar_plot", icon = icon("image")),
               menuSubItem(text = "Lollipop Plot", tabName = "lollipop_plot", icon = icon("image"))
               #menuSubItem(text = "Treemap Plot", tabName = "treemap_plot", icon = icon("image"))
      ),
      
      # Advance Plot
      menuItem(text = "Advance Plot", icon = icon("area-chart"), startExpanded = FALSE,
               menuSubItem(text = "Correlation_Matrix", tabName = "correlation_matrix", icon = icon("image")),
               menuSubItem(text = "Correlation_Point", tabName = "correlation_point", icon = icon("image")),
               menuSubItem(text = "Clustering Plot", tabName = "clustering_plot", icon = icon("image")),
               menuSubItem(text = "PCA", tabName = "pca", icon = icon("image")),
               menuSubItem(text = "PCoA", tabName = "pcoa", icon = icon("image")),
               menuSubItem(text = "t-SNE", tabName = "tsne", icon = icon("image")),
               menuSubItem(text = "UMAP", tabName = "umap", icon = icon("image")),
               menuSubItem(text = "RDA", tabName = "RDA", icon = icon("image")),
               menuSubItem(text = "NMDS", tabName = "nmds", icon = icon("image")),
               menuSubItem(text = "Sanky", tabName = "sanky", icon = icon("image")),
               menuSubItem(text = "Chord Diagram", tabName = "chord_diagram", icon = icon("image")),
               menuSubItem(text = "Raincloud Plot", tabName = "raincloud_plot", icon = icon("image")),
               menuSubItem(text = "Ternary Plot", tabName = "ternary_plot", icon = icon("image")),
               menuSubItem(text = "Volcano Plot", tabName = "volcano_plot", icon = icon("image")),
               menuSubItem(text = "Venn Plot", tabName = "venn_plot", icon = icon("image")),
               menuSubItem(text = "Heatmap", tabName = "heatmap", icon = icon("image")),
               menuSubItem(text = "Word Cloud", tabName = "word_cloud", icon = icon("image"))
      ),
      
      # Statistical Analysis
      menuItem(text = "Statistical Analysis", icon = icon("calculator"), startExpanded = FALSE,
               menuSubItem(text = "Linear Fitting", tabName = "linear_fitting"),
               menuSubItem(text = "One-way ANOVA", tabName = "one-way_anova"),
               menuSubItem(text = "Two-way ANOVA", tabName = "two-way_anova"),
               menuSubItem(text = "Chi-square test", tabName = "chi-square_test"),
               menuSubItem(text = "Generalized Linear Model", tabName = "generalized_linear_model"),
               menuSubItem(text = "Logistic Regression", tabName = "logistic_regression"),
               menuSubItem(text = "Possion Regression", tabName = "possion_regression"),
               menuSubItem(text = "Structural Equation Model", tabName = "sem")
      ),
      
      # Time-Series Analysis
      menuItem(text = "Time-Series", icon = icon("line-chart"), startExpanded = FALSE,
               menuSubItem(text = "Time-Series", tabName = "time_series"),
               menuSubItem(text = "Multi-Time-Series", tabName = "multi_time_series")
      ),
      
      # Map
      menuItem(text = "Map", icon = icon("globe"), startExpanded = FALSE,
               menuSubItem(text = "China Map", tabName = "china_map"),
               menuSubItem(text = "China Map (Interactive)", tabName = "china_map_interactive"),
               menuSubItem(text = "World Map", tabName = "world_map"),
               menuSubItem(text = "World Map (Interactive)", tabName = "world_map_interactive")
      ),
      
      # Bioinformatics
      menuItem(text = "Bioinformatics", icon = icon("dna"), startExpanded = FALSE,
               menuSubItem(text = "Seqfinder", tabName = "seqfinder"),
               menuSubItem(text = "Mutmaper", tabName = "mutmaper"),
               menuSubItem(text = "DEG Analysis", tabName = "deg_analysis"),
               menuSubItem(text = "DAS Analysis", tabName = "das_analysis"),
               menuSubItem(text = "DTU Analysis", tabName = "dtu_analysis"),
               menuSubItem(text = "Enrichment Analysis", tabName = "enrichment_analysis")
      ),
      
      # Microbiome
      menuItem(text = "Microbiome", icon = icon("bacteria"), startExpanded = FALSE,
               menuSubItem(text = "Microbial Diversity", tabName = "microbiome_diversity"),
               menuSubItem(text = "Microbial Community", tabName = "microbiome_community"),
               menuSubItem(text = "Microbiome Dashboard", tabName = "microbiome_dashboard")
      ),
      
      # Network
      menuItem(
        text = "Network", icon = icon("circle-nodes"), startExpanded = FALSE,
        menuSubItem(text = "Network", tabName = "network")
      ),
      
      # Atom
      menuItem(text = "isotope", icon = icon("atom"), startExpanded = FALSE,
               menuSubItem(text = "isotope1", tabName = "isotope1"),
               menuSubItem(text = "isotope2", tabName = "isotope2"),
               menuSubItem(text = "isotope3", tabName = "isotope3")
      ),
      
      # Agriculture
      menuItem(text = "Agriculture", 
               # icon = icon("planting.png", class = "image"), 
               icon = icon("pagelines"),
               startExpanded = FALSE,
               menuSubItem(text = "Agriculture1", tabName = "Agriculture1"),
               menuSubItem(text = "Agriculture2", tabName = "Agriculture2"),
               menuSubItem(text = "Agriculture3", tabName = "Agriculture3")
        
      ),
      # highcharter
      menuItem(text = "Highcharter", icon = icon("uncharted"), startExpanded = FALSE,
               menuSubItem(text = "Histogram", tabName = "histogram_highcharter"),
               menuSubItem(text = "Densities", tabName = "densities_highcharter"),
               menuSubItem(text = "Bar Plot", tabName = "barplot_highcharter"),
               menuSubItem(text = "Time Series", tabName = "time_series_highcharter"),
               menuSubItem(text = "Multivariance Time Series", tabName = "multitime_series_highcharter"),
               menuSubItem(text = "Distance Matrix", tabName = "distance_matrix_highcharter"),
               menuSubItem(text = "Correlation Matrix", tabName = "correlation_matrix_highcharter")
      ),
      
      # Data Trans
      menuItem(text = "Data Transformation", icon = icon("table"), startExpanded = FALSE,
               menuSubItem(text = "Missing Value", tabName = "missing_value"),
               menuSubItem(text = "Outlier Value", tabName = "outlier_value"),
               menuSubItem(text = "Wide to long", tabName = "wide2long"),
               menuSubItem(text = "Long to wide", tabName = "long2wide"),
               menuSubItem(text = "csv to txt", tabName = "csv2txt"),
               menuSubItem(text = "csv to excel", tabName = "csv2excel"),
               menuSubItem(text = "txt to csv", tabName = "txt2csv")
      ),
      
      # Developer
      menuItem(text = "Developer", tabName = "developer", icon = icon("user")),
      
      # R book
      menuItem(text = "R&Python", tabName = "rpython", icon = icon("book"))
      
    ),
  ),
  
  body = dashboardBody(
    tabItems(
      # homepage
      homepage(),
      # Introduction
      Introduction_UI("introduction_markdown"),
      # file_upload(),
      # basic plot
      basic_advance_plot_UI(tabName = "dot_plot", inputid = "dot_plot", title = "Dot Plot", fun = "ggplot2_parameters_dotplot_UI"),
      basic_advance_plot_UI(tabName = "bubble_plot", inputid = "bubble_plot", title = "Bubble Plot", fun = "ggplot2_parameters_bubble_UI"),
      basic_advance_plot_UI(tabName = "bar_plot", inputid = "bar_plot", title = "Bar Plot", fun = "ggplot2_parameters_barplot_UI"),
      basic_advance_plot_UI(tabName = "line_plot", inputid = "line_plot", title = "Line Plot", fun = "ggplot2_parameters_line_UI"),
      basic_advance_plot_UI(tabName = "smooth_line_plot", inputid = "smooth_line_plot", title = "Smooth Line Plot", fun = "ggplot2_parameters_smooth_line_UI"),
      basic_advance_plot_UI(tabName = "box_plot", inputid = "box_plot", title = "Box Plot", fun = "ggplot2_parameters_boxplot_UI"),
      basic_advance_plot_UI(tabName = "violin_plot", inputid = "violin_plot", title = "Violin Plot", fun = "ggplot2_parameters_violin_UI"),
      basic_advance_plot_UI(tabName = "pie_plot", inputid = "pie_plot", title = "Pie Plot", fun = "ggplot2_parameters_pieplot_UI"),
      basic_advance_plot_UI(tabName = "dount_plot", inputid = "dount_plot", title = "Dount Plot", fun = "ggplot2_parameters_dountplot_UI"),
      basic_advance_plot_UI(tabName = "density_plot", inputid = "density_plot", title = "Density Plot", fun = "ggplot2_parameters_density_plot_UI"),
      basic_advance_plot_UI(tabName = "density_plot2", inputid = "density_plot2", title = "Density Plot 2", fun = "ggplot2_parameters_density_plot_2_UI"),
      basic_advance_plot_UI(tabName = "histogram_plot", inputid = "histogram_plot", title = "Histogram Plot", fun = "ggplot2_parameters_histogram_plot_UI"),
      basic_advance_plot_UI(tabName = "ridgeline_plot", inputid = "ridgeline_plot", title = "Ridgeline Plot", fun = "ggplot2_parameters_rigeline_UI"),
      basic_advance_plot_UI(tabName = "radar_plot", inputid = "radar_plot", title = "Radar Plot", fun = "ggplot2_parameters_radar_plot_UI"),
      basic_advance_plot_UI(tabName = "lollipop_plot", inputid = "lollipop_plot", title = "Lollipop Plot", fun = "ggplot2_parameters_lollipop_UI"),
      #
      #
      # advance plot
      basic_advance_plot_UI(tabName = "pca", inputid = "pca", title = "PCA Plot", fun = "ggplot2_parameters_pca_UI"),
      basic_advance_plot_UI(tabName = "pcoa", inputid = "pcoa", title = "PCoA Plot", fun = "ggplot2_parameters_pcoa_UI"),
      basic_advance_plot_UI(tabName = "tsne", inputid = "tsne", title = "t-SNE Plot", fun = "ggplot2_parameters_tsne_UI"),
      basic_advance_plot_UI(tabName = "umap", inputid = "umap", title = "UMAP Plot", fun = "ggplot2_parameters_umap_UI"),

      basic_advance_plot_UI(tabName = "volcano_plot", inputid = "volcano_plot", title = "Volcano Plot", fun = "ggplot2_parameters_volcano_UI"),

      developer(),
      rpython()
    )
  ),
  controlbar = dashboardControlbar(
    collapsed = TRUE,
    div(class = "p-3", skinSelector()),
    pinned = TRUE
  ),
  title = "BGCViewer: a web-tool for data visualization",
  footer = dashboardFooter(
    left = a(href = "http://www.iae.cas.cn/biogeochemistry/",
             targrt = "_blank" ,"版权所有 © 中国科学院沈阳应用生态研究所-生物地球化学组     地址：沈阳市沈河区文化路72号　邮编：110016"),
    right = "2023",
    fixed = TRUE
  ),
  fullscreen = TRUE,
  scrollToTop = TRUE,
  help = TRUE,
  preloader = list(html = tagList(spin_1(), "Loading ..."), color = "#343a40")
)


# Server function
server <-  function(input, output, session) {
  # # test module
  # file_upload_Server("test_input")
  
  # Introduction
  # Introduction_4Server("introduction_markdown")
  # carousel
  myCarousel_Server("myCarousel")
  
  # dot_plot
  file_upload_Server("dot_plot")
  ggplot2_dotplot_Server("dot_plot")
  show_example_data_Server("dot_plot", "mtcars_df")

  # bubble_plot
  file_upload_Server("bubble_plot")
  ggplot2_bubble_plot_Server("bubble_plot")
  show_example_data_Server("bubble_plot", "mtcars_df")


  # bar_plot
  file_upload_Server("bar_plot")
  ggplot2_barplot_Server("bar_plot")
  show_example_data_Server("bar_plot", "barplot_df")

  # line_plot
  file_upload_Server("line_plot")
  ggplot2_lineplot_Server("line_plot")
  show_example_data_Server("line_plot", "line_df")

  # smooth_line_plot
  file_upload_Server("smooth_line_plot")
  ggplot2_smooth_lineplot_Server("smooth_line_plot")
  show_example_data_Server("smooth_line_plot", "smooth_df")

  # box_plot
  file_upload_Server("box_plot")
  ggplot2_boxplot_Server("box_plot")
  show_example_data_Server("box_plot", "boxplot_df")

  # violin_plot
  file_upload_Server("violin_plot")
  ggplot2_violin_Server("violin_plot")
  show_example_data_Server("violin_plot", "violin_df")

  # pie_plot
  file_upload_Server("pie_plot")
  ggplot2_pieplot_Server("pie_plot")
  show_example_data_Server("pie_plot", "pie_df")

  # dount_plot
  file_upload_Server("dount_plot")
  ggplot2_dountplot_Server("dount_plot")
  show_example_data_Server("dount_plot", "pie_df")

  # density_plot
  file_upload_Server("density_plot")
  ggplot2_density_plot_Server("density_plot")
  show_example_data_Server("density_plot", "density_df")

  # density_plot 2
  file_upload_Server("density_plot2")
  ggplot2_density_plot_2_Server("density_plot2")
  show_example_data_Server("density_plot2", "density_df")

  # histogram plot
  file_upload_Server("histogram_plot")
  ggplot2_histogram_plot_Server("histogram_plot")
  show_example_data_Server("histogram_plot", "histogram_df")

  # ridgeline_plot
  file_upload_Server("ridgeline_plot")
  ggplot2_rigeline_Server("ridgeline_plot")
  show_example_data_Server("ridgeline_plot", "diamond_df")

  # lollipop_plot
  file_upload_Server("lollipop_plot")
  ggplot2_lollipop_plot_Server("lollipop_plot")
  show_example_data_Server("lollipop_plot", "lollipop_df")

  # radar plot
  file_upload_Server("radar_plot")
  ggplot2_radar_plot_Server("radar_plot")
  show_example_data_Server("radar_plot", "radar_df")

  # Advance plot
  # PCA
  file_upload_Server("pca")
  ggplot2_pca_Server("pca")
  show_example_data_Server("pca", "iris_df")

  # PCoA
  file_upload_Server("pcoa")
  ggplot2_pcoa_Server("pcoa")
  show_example_data_Server("pcoa", "iris_df")

  # tSNE
  file_upload_Server("tsne")
  ggplot2_tsne_Server("tsne")
  show_example_data_Server("tsne", "iris_df")

  # UMAP
  file_upload_Server("umap")
  ggplot2_umap_Server("umap")
  show_example_data_Server("umap", "iris_df")

  # violin_plot
  file_upload_Server("volcano_plot")
  ggplot2_volcano_Server("volcano_plot")
  show_example_data_Server("volcano_plot", "violent_df")
  
}

# Run App
shinyApp(ui, server)
