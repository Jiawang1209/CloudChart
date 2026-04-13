root_dir <- getwd()
source(file.path(root_dir, "R", "app_bootstrap.R"), local = TRUE)
bgc_bootstrap(root_dir, groups = c("core", "advanced"))
