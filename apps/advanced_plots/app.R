root_dir <- normalizePath(file.path(getwd(), "..", ".."), winslash = "/", mustWork = TRUE)

source(file.path(root_dir, "R", "core", "app_bootstrap.R"))
bgc_bootstrap(root_dir, groups = "advanced")

ui <- bgc_plot_app_ui("CloudChart Advanced", groups = "advanced")
server <- bgc_plot_app_server(groups = "advanced", include_home = TRUE)

shinyApp(ui, server)
