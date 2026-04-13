root_dir <- getwd()

source(file.path(root_dir, "R", "core", "app_bootstrap.R"))

groups <- c("core", "advanced", "statistics", "data_tools")
bgc_bootstrap(root_dir, groups = groups)

ui <- bgc_plot_app_ui(
  app_title = "CloudChart",
  groups = groups,
  include_home = TRUE,
  include_intro = TRUE
)
server <- bgc_plot_app_server(groups = groups, include_home = TRUE)

shinyApp(ui, server)
