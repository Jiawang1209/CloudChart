root_dir <- normalizePath(file.path(getwd(), "..", ".."), mustWork = TRUE)
source(file.path(root_dir, "R", "core", "app_bootstrap.R"))

group_name <- "replace_with_group_name"
app_title <- "CloudChart New Domain"

bgc_bootstrap(root_dir, groups = group_name)

ui <- bgc_plot_app_ui(
  app_title = app_title,
  groups = group_name,
  include_home = TRUE,
  include_intro = TRUE
)
server <- bgc_plot_app_server(groups = group_name, include_home = TRUE)

shinyApp(ui, server)
