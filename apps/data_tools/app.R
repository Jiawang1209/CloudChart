root_dir <- normalizePath(file.path(getwd(), "..", ".."), winslash = "/", mustWork = TRUE)

source(file.path(root_dir, "R", "core", "app_bootstrap.R"))
bgc_bootstrap(root_dir, groups = "data_tools")

ui <- bgc_plot_app_ui("CloudChart Data Tools", groups = "data_tools")
server <- bgc_plot_app_server(groups = "data_tools", include_home = TRUE)

shinyApp(ui, server)
