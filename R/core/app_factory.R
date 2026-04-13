bgc_head <- function() {
  bs4Dash::bs4DashHead(
    tags$style(HTML("
      .bgc-advanced-options {
        margin-top: 1rem;
        padding: 0.9rem 1rem;
        border: 1px solid #d7dee7;
        border-radius: 0.75rem;
        background: #f8fafc;
      }
      .bgc-advanced-options summary {
        cursor: pointer;
        font-weight: 600;
        color: #1f3b5b;
        outline: none;
      }
      .bgc-advanced-options__body {
        margin-top: 0.9rem;
      }
    ")),
    tags$script(src = "https://code.jquery.com/jquery-3.5.1.min.js"),
    tags$link(
      rel = "stylesheet",
      href = "https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/css/bootstrap.min.css"
    ),
    tags$script(src = "https://stackpath.bootstrapcdn.com/bootstrap/4.5.0/js/bootstrap.min.js")
  )
}

bgc_header <- function(title = "CloudChart") {
  dashboardHeader(
    title = dashboardBrand(
      title = title,
      color = "lightblue",
      href = "http://www.iae.cas.cn/biogeochemistry/",
      image = "https://adminlte.io/themes/v3/dist/img/AdminLTELogo.png"
    )
  )
}

bgc_footer <- function() {
  dashboardFooter(
    left = a(
      href = "http://www.iae.cas.cn/biogeochemistry/",
      targrt = "_blank",
      "版权所有 © 中国科学院沈阳应用生态研究所-生物地球化学组     地址：沈阳市沈河区文化路72号　邮编：110016"
    ),
    right = "2023",
    fixed = TRUE
  )
}

bgc_sidebar_group <- function(text, icon_name, specs) {
  submenu_items <- lapply(
    specs,
    function(spec) {
      item_icon <- if (!is.null(spec$icon) && nzchar(spec$icon)) spec$icon else "image"
      menuSubItem(text = spec$title, tabName = spec$id, icon = icon(item_icon))
    }
  )

  do.call(
    menuItem,
    c(
      list(text = text, icon = icon(icon_name), startExpanded = TRUE),
      submenu_items
    )
  )
}

bgc_placeholder_tab_name <- function(group) {
  paste0(group, "_placeholder")
}

bgc_placeholder_menu <- function(group) {
  cfg <- bgc_group_menu_config[[group]]
  menuItem(
    text = cfg$label,
    tabName = bgc_placeholder_tab_name(group),
    icon = icon(cfg$icon)
  )
}

bgc_placeholder_tab <- function(group) {
  meta <- bgc_reserved_apps[[group]]
  cfg <- bgc_group_menu_config[[group]]
  title <- if (!is.null(meta)) meta$title else cfg$label
  subtitle <- if (!is.null(meta)) meta$subtitle else "This area is reserved for future modules."
  next_steps <- if (!is.null(meta)) meta$next_steps else character()

  tabItem(
    tabName = bgc_placeholder_tab_name(group),
    fluidPage(
      fluidRow(
        column(
          width = 12,
          box(
            width = 12,
            title = title,
            status = "info",
            solidHeader = TRUE,
            p(subtitle),
            p("This area is reserved as a clean scaffold for future modules.")
          )
        )
      ),
      if (length(next_steps) > 0) {
        fluidRow(
          column(
            width = 12,
            box(
              width = 12,
              title = "Suggested Next Steps",
              status = "secondary",
              solidHeader = TRUE,
              lapply(next_steps, p)
            )
          )
        )
      }
    )
  )
}

bgc_plot_tabs <- function(specs) {
  lapply(
    specs,
    function(spec) {
      layout <- if (is.null(spec$layout)) "plot" else spec$layout
      ui_fn <- switch(
        layout,
        stats = basic_stats_UI,
        data_tools = basic_data_tools_UI,
        basic_advance_plot_UI
      )
      ui_fn(
        tabName = spec$id,
        inputid = spec$id,
        title = spec$title,
        fun = spec$parameter_ui
      )
    }
  )
}

bgc_register_plot_servers <- function(specs) {
  for (spec in specs) {
    if (!is.null(spec$example_data) && nzchar(spec$example_data)) {
      show_example_data_Server(spec$id, spec$example_data)
    }
    file_upload_Server(spec$id)
    get(spec$server_fun)(spec$id)
  }
}

bgc_plot_app_ui <- function(app_title, groups, include_home = TRUE, include_intro = TRUE) {
  sidebar_items <- list()
  body_items <- list()

  if (include_home) {
    sidebar_items <- c(
      sidebar_items,
      list(menuItem(text = "Home Page", tabName = "home_page", icon = icon("house")))
    )
    body_items <- c(body_items, list(homepage()))
  }

  if (include_intro) {
    sidebar_items <- c(
      sidebar_items,
      list(menuItem(text = "Introduction", tabName = "introduction", icon = icon("question")))
    )
    body_items <- c(body_items, list(Introduction_UI("introduction_markdown")))
  }

  for (group in groups) {
    group_specs <- bgc_plot_specs[[group]]
    if (length(group_specs) == 0) {
      sidebar_items <- c(sidebar_items, list(bgc_placeholder_menu(group)))
      body_items <- c(body_items, list(bgc_placeholder_tab(group)))
    } else {
      sidebar_items <- c(
        sidebar_items,
        list(bgc_sidebar_group(
          bgc_group_menu_config[[group]]$label,
          bgc_group_menu_config[[group]]$icon,
          group_specs
        ))
      )
      body_items <- c(body_items, bgc_plot_tabs(group_specs))
    }
  }

  dashboardPage(
    bgc_head(),
    header = bgc_header(app_title),
    sidebar = dashboardSidebar(
      width = 220,
      do.call(sidebarMenu, c(list(id = "sidebarmenu"), sidebar_items))
    ),
    body = dashboardBody(do.call(tabItems, body_items)),
    controlbar = dashboardControlbar(
      collapsed = TRUE,
      div(class = "p-3", skinSelector()),
      pinned = TRUE
    ),
    title = paste0(app_title, ": a web-tool for data visualization"),
    footer = bgc_footer(),
    fullscreen = TRUE,
    scrollToTop = TRUE,
    help = TRUE,
    preloader = list(html = tagList(waiter::spin_1(), "Loading ..."), color = "#343a40")
  )
}

bgc_plot_app_server <- function(groups, include_home = TRUE) {
  force(groups)
  force(include_home)

  # tab id → group lookup, so navigation events can find the right group to load.
  tab_to_group <- list()
  for (group in groups) {
    for (spec in bgc_plot_specs[[group]]) {
      tab_to_group[[spec$id]] <- group
    }
  }

  function(input, output, session) {
    if (include_home) {
      myCarousel_Server("myCarousel")
    }

    # Per-session tracker — module servers must be wired once per Shiny session,
    # even if the R process already attached the packages for a previous session.
    activated <- new.env(parent = emptyenv())

    activate_group <- function(group) {
      if (isTRUE(activated[[group]])) return(invisible())
      bgc_ensure_group_loaded(group)
      bgc_register_plot_servers(bgc_plot_specs[[group]])
      activated[[group]] <- TRUE
    }

    observeEvent(input$sidebarmenu, {
      tab <- input$sidebarmenu
      grp <- tab_to_group[[tab]]
      if (!is.null(grp)) activate_group(grp)
    }, ignoreInit = FALSE)
  }
}

bgc_reserved_app_ui <- function(app_key, include_intro = TRUE) {
  app_meta <- bgc_reserved_apps[[app_key]]

  sidebar_items <- list(
    menuItem(text = "Overview", tabName = "reserved_home", icon = icon("house"))
  )
  body_items <- list(
    tabItem(
      tabName = "reserved_home",
      fluidPage(
        fluidRow(
          column(
            width = 12,
            box(
              width = 12,
              title = app_meta$title,
              status = "info",
              solidHeader = TRUE,
              p(app_meta$subtitle),
              p("This app is reserved as a clean scaffold for future modules.")
            )
          )
        ),
        fluidRow(
          column(
            width = 12,
            box(
              width = 12,
              title = "Suggested Next Steps",
              status = "secondary",
              solidHeader = TRUE,
              lapply(app_meta$next_steps, p)
            )
          )
        )
      )
    )
  )

  if (include_intro) {
    sidebar_items <- c(
      sidebar_items,
      list(menuItem(text = "Introduction", tabName = "introduction", icon = icon("question")))
    )
    body_items <- c(body_items, list(Introduction_UI("introduction_markdown")))
  }

  dashboardPage(
    bgc_head(),
    header = bgc_header(app_meta$title),
    sidebar = dashboardSidebar(
      width = 120,
      do.call(sidebarMenu, c(list(id = "sidebarmenu"), sidebar_items))
    ),
    body = dashboardBody(do.call(tabItems, body_items)),
    controlbar = dashboardControlbar(
      collapsed = TRUE,
      div(class = "p-3", skinSelector()),
      pinned = TRUE
    ),
    title = app_meta$title,
    footer = bgc_footer(),
    fullscreen = TRUE,
    scrollToTop = TRUE,
    help = TRUE,
    preloader = list(html = tagList(waiter::spin_1(), "Loading ..."), color = "#343a40")
  )
}

bgc_reserved_app_server <- function() {
  function(input, output, session) {
  }
}

bgc_launch_modal <- function(app_title, run_command, description) {
  modalDialog(
    title = paste("Open", app_title),
    easyClose = TRUE,
    footer = modalButton("Close"),
    p(description),
    tags$p("Run this command in RStudio or the R console:"),
    tags$pre(
      style = "background: #f6f8fa; padding: 12px; border-radius: 8px;",
      run_command
    )
  )
}

bgc_app_launch_card <- function(title, status, description, run_command, button_id) {
  box(
    width = 12,
    title = title,
    status = status,
    solidHeader = TRUE,
    p(description),
    p(paste("Run locally with:", run_command)),
    actionBttn(
      inputId = button_id,
      label = "Show Launch Command",
      color = "primary",
      style = "bordered"
    )
  )
}

bgc_portal_home <- function() {
  tabItem(
    tabName = "portal_home",
    fluidPage(
      fluidRow(
        column(
          width = 12,
          align = "center",
          tags$br(),
          img(src = "bgc-www/CloudChart.png", width = "220px"),
          h1("CloudChart App Hub"),
          p(
            style = "font-size: 18px; max-width: 900px; margin: 0 auto;",
            "Use a lightweight portal at the top level and split plotting domains into independent sub apps. This keeps startup fast and makes future features easier to maintain."
          )
        )
      ),
      fluidRow(
        column(
          width = 6,
          bgc_app_launch_card(
            title = "Core Plots App",
            status = "info",
            description = "Basic exploratory plots such as dot, bubble, bar, line and box.",
            run_command = "shiny::runApp('apps/core_plots')",
            button_id = "open_core_plots_help"
          )
        ),
        column(
          width = 6,
          bgc_app_launch_card(
            title = "Advanced Plots App",
            status = "primary",
            description = "Dimension reduction and differential analysis plots such as PCA, UMAP and volcano.",
            run_command = "shiny::runApp('apps/advanced_plots')",
            button_id = "open_advanced_plots_help"
          )
        )
      ),
      fluidRow(
        column(
          width = 6,
          bgc_app_launch_card(
            title = "Statistics App",
            status = "warning",
            description = "Reserved scaffold for statistical analysis, testing and model workflows.",
            run_command = "shiny::runApp('apps/statistics')",
            button_id = "open_statistics_help"
          )
        ),
        column(
          width = 6,
          bgc_app_launch_card(
            title = "Data Tools App",
            status = "success",
            description = "Reserved scaffold for import, cleaning, reshaping and export utilities.",
            run_command = "shiny::runApp('apps/data_tools')",
            button_id = "open_data_tools_help"
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          box(
            width = 12,
            title = "Why Split",
            status = "secondary",
            solidHeader = TRUE,
            p("1. Each app can evolve independently."),
            p("2. Heavy dependencies stay inside the app that needs them."),
            p("3. New future domains can be added under apps/ without touching the whole product.")
          )
        )
      )
    )
  )
}

bgc_portal_ui <- function() {
  dashboardPage(
    bgc_head(),
    header = bgc_header("CloudChart Hub"),
    sidebar = dashboardSidebar(
      width = 120,
      sidebarMenu(
        id = "sidebarmenu",
        menuItem(text = "App Hub", tabName = "portal_home", icon = icon("house")),
        menuItem(text = "Introduction", tabName = "introduction", icon = icon("question"))
      )
    ),
    body = dashboardBody(
      do.call(
        tabItems,
        list(
          bgc_portal_home(),
          Introduction_UI("introduction_markdown")
        )
      )
    ),
    controlbar = dashboardControlbar(
      collapsed = TRUE,
      div(class = "p-3", skinSelector()),
      pinned = TRUE
    ),
    title = "CloudChart Hub",
    footer = bgc_footer(),
    fullscreen = TRUE,
    scrollToTop = TRUE,
    help = TRUE,
    preloader = list(html = tagList(waiter::spin_1(), "Loading ..."), color = "#343a40")
  )
}

bgc_portal_server <- function(input, output, session) {
  observeEvent(input$open_core_plots_help, {
    showModal(
      bgc_launch_modal(
        "Core Plots App",
        "shiny::runApp('apps/core_plots')",
        "Use this app for the main exploratory plotting workflow."
      )
    )
  })

  observeEvent(input$open_advanced_plots_help, {
    showModal(
      bgc_launch_modal(
        "Advanced Plots App",
        "shiny::runApp('apps/advanced_plots')",
        "Use this app for PCA, UMAP and volcano analysis."
      )
    )
  })

  observeEvent(input$open_statistics_help, {
    showModal(
      bgc_launch_modal(
        "Statistics App",
        "shiny::runApp('apps/statistics')",
        "This is the reserved scaffold for future statistical workflows."
      )
    )
  })

  observeEvent(input$open_data_tools_help, {
    showModal(
      bgc_launch_modal(
        "Data Tools App",
        "shiny::runApp('apps/data_tools')",
        "This is the reserved scaffold for future data cleaning and transformation workflows."
      )
    )
  })
}
