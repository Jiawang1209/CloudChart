root_dir <- normalizePath(file.path(getwd(), "..", ".."), winslash = "/", mustWork = TRUE)

source(file.path(root_dir, "R", "core", "app_bootstrap.R"))
bgc_bootstrap(root_dir, groups = "core")

ui <- bgc_plot_app_ui("CloudChart Core", groups = "core")
server <- bgc_plot_app_server(groups = "core", include_home = TRUE)

shinyApp(ui, server)
