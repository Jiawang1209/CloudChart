bgc_head <- function() {
  tags$head(
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
      .bgc-home-flex { display: flex; align-items: stretch; margin-bottom: 1rem; }
      .bgc-home-flex > [class*='col-'] { display: flex; }
      .bgc-home-flex > [class*='col-'] > .card {
        width: 100%;
        height: 100%;
        margin-bottom: 0;
        display: flex;
        flex-direction: column;
      }
      .bgc-home-flex > [class*='col-'] > .card > .card-body {
        flex: 1 1 auto;
      }
      .bgc-home-box .card-tools { display: none !important; }

      .bgc-home-title {
        margin-top: 0.6rem;
        font-weight: 700;
        letter-spacing: 0.02em;
        color: #1f3b5b;
      }
      .bgc-home-subtitle {
        font-size: 17px;
        max-width: 880px;
        margin: 0.4rem auto 0;
        color: #5b6b7f;
      }

      .bgc-section-header {
        margin: 2rem 0 0.9rem;
        padding-bottom: 0.4rem;
        border-bottom: 1px solid #e3e8ef;
      }
      .bgc-section-header h3 {
        margin: 0;
        font-size: 1.25rem;
        font-weight: 700;
        color: #1f3b5b;
        letter-spacing: 0.01em;
      }
      .bgc-section-header p {
        margin: 0.25rem 0 0;
        color: #6b7a90;
        font-size: 0.95rem;
      }

      .bgc-feature-row { display: flex; flex-wrap: wrap; align-items: stretch; margin-bottom: 0.5rem; }
      .bgc-feature-card {
        background: #ffffff;
        border: 1px solid #e3e8ef;
        border-radius: 14px;
        padding: 1.1rem 1.15rem 1rem;
        box-shadow: 0 1px 3px rgba(15, 30, 60, 0.04);
        display: flex;
        flex-direction: column;
        margin-bottom: 1rem;
        transition: transform 120ms ease, box-shadow 120ms ease;
      }
      .bgc-feature-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 8px 20px rgba(15, 30, 60, 0.08);
      }
      .bgc-feature-card__head {
        display: flex;
        align-items: center;
        gap: 0.8rem;
        margin-bottom: 0.6rem;
      }
      .bgc-feature-card__icon {
        width: 42px; height: 42px;
        border-radius: 10px;
        color: #ffffff;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 18px;
        flex: 0 0 auto;
      }
      .bgc-feature-card__title {
        font-weight: 700;
        font-size: 1rem;
        color: #1f3b5b;
        line-height: 1.25;
      }
      .bgc-feature-card__count {
        font-size: 0.82rem;
        color: #6b7a90;
        margin-top: 0.15rem;
      }
      .bgc-feature-card__desc {
        margin: 0;
        color: #4d5d73;
        font-size: 0.92rem;
        line-height: 1.55;
      }

      .bgc-contact-row { display: flex; flex-wrap: wrap; align-items: stretch; margin-bottom: 1rem; }
      .bgc-contact-cell { padding: 0.6rem 0; }
      .bgc-contact-img {
        border-radius: 10px;
        border: 1px solid #e3e8ef;
        padding: 4px;
        background: #ffffff;
      }
      .bgc-contact-label {
        margin-top: 0.5rem;
        color: #5b6b7f;
        font-size: 0.9rem;
      }
    "))
  )
}

bgc_header <- function(title = "CloudChart") {
  dashboardHeader(
    title = dashboardBrand(
      title = title,
      color = "lightblue",
      href = "http://www.iae.cas.cn/biogeochemistry/",
      image = "bgc-www/CloudChart.png"
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

bgc_body_fn_for <- function(spec) {
  layout <- if (is.null(spec$layout)) "plot" else spec$layout
  switch(
    layout,
    stats      = basic_stats_body,
    data_tools = basic_data_tools_body,
    basic_advance_plot_body
  )
}

bgc_plot_tabs <- function(specs) {
  lapply(
    specs,
    function(spec) {
      tabItem(
        tabName = spec$id,
        header_tabItem(title = spec$title),
        uiOutput(NS(spec$id, "tab_body"))
      )
    }
  )
}

bgc_register_plot_servers <- function(specs, group, active_tab, output) {
  force(specs)
  force(group)
  for (spec in specs) local({
    spec <- spec
    group <- group
    installed <- FALSE
    body_fn <- bgc_body_fn_for(spec)

    observeEvent(active_tab(), {
      if (!identical(active_tab(), spec$id)) return()
      if (installed) return()

      bgc_log("tab click: ", spec$id, " (group=", group, ")", level = "info")
      loaded_ok <- tryCatch(
        bgc_ensure_group_loaded(group),
        error = function(e) {
          bgc_log("ensure_group_loaded('", group, "') FAILED for ",
                  spec$id, ": ", conditionMessage(e), level = "warn")
          FALSE
        }
      )
      if (!isTRUE(bgc_loaded_groups[[group]])) {
        bgc_log("spec ", spec$id, " aborted: group '", group,
                "' not fully loaded", level = "warn")
        return()
      }
      bgc_log("search path has ggplot2? ",
              "package:ggplot2" %in% search(),
              " | exists(ggplot)? ",
              exists("ggplot", mode = "function", inherits = TRUE),
              level = "info")
      installed <<- TRUE

      output[[paste0(spec$id, "-tab_body")]] <- renderUI({
        body_fn(spec$id, spec$parameter_ui)
      })

      if (!is.null(spec$example_data) && nzchar(spec$example_data)) {
        show_example_data_Server(spec$id, spec$example_data)
      }
      file_upload_Server(spec$id)
      tryCatch(
        get(spec$server_fun)(spec$id),
        error = function(e) {
          bgc_log("server_fun FAILED for ", spec$id, ": ", conditionMessage(e),
                  level = "warn")
        }
      )
    }, ignoreNULL = TRUE, ignoreInit = FALSE)
  })
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
      stop(sprintf("No modules registered for group '%s' in bgc_plot_specs.", group))
    }
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

  dashboardPage(
    header = bgc_header(app_title),
    sidebar = dashboardSidebar(
      width = 240,
      collapsed = FALSE,
      minified = FALSE,
      expandOnHover = FALSE,
      fixed = TRUE,
      do.call(sidebarMenu, c(list(id = "sidebarmenu"), sidebar_items))
    ),
    body = dashboardBody(bgc_head(), do.call(tabItems, body_items)),
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

  function(input, output, session) {
    active_tab <- reactive(input$sidebarmenu)
    for (group in groups) {
      bgc_register_plot_servers(bgc_plot_specs[[group]], group, active_tab, output)
    }
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
      bgc_head(),
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
