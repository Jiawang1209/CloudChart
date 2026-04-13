root_dir <- normalizePath(file.path(getwd(), "..", ".."), winslash = "/", mustWork = TRUE)

source(file.path(root_dir, "R", "core", "app_bootstrap.R"))
bgc_bootstrap(root_dir, groups = "statistics")

ui <- bgc_plot_app_ui("CloudChart Statistics", groups = "statistics")
server <- bgc_plot_app_server(groups = "statistics", include_home = TRUE)

shinyApp(ui, server)
