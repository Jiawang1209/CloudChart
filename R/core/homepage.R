homepage <- function(){

  group_count <- function(group) {
    specs <- tryCatch(bgc_plot_specs[[group]], error = function(e) NULL)
    if (is.null(specs)) 0L else length(specs)
  }

  n_core       <- group_count("core")
  n_advanced   <- group_count("advanced")
  n_statistics <- group_count("statistics")
  n_data_tools <- group_count("data_tools")

  feature_card <- function(title, count, description, icon_name, accent) {
    tags$div(
      class = "col-md-6 col-lg-3 d-flex",
      tags$div(
        class = "bgc-feature-card w-100",
        style = sprintf("border-top: 4px solid %s;", accent),
        tags$div(
          class = "bgc-feature-card__head",
          tags$span(
            class = "bgc-feature-card__icon",
            style = sprintf("background: %s;", accent),
            icon(icon_name)
          ),
          tags$div(
            tags$div(class = "bgc-feature-card__title", title),
            tags$div(class = "bgc-feature-card__count", paste0(count, " modules"))
          )
        ),
        tags$p(class = "bgc-feature-card__desc", description)
      )
    )
  }

  tabItem(
    tabName = "home_page",
    fluidPage(
      fluidRow(
        column(
          width = 12,
          align = "center",
          tags$br(),
          img(
            src = "bgc-www/CloudChart.png",
            width = "300px"
          ),
          tags$br(),
          h1("CloudChart", class = "bgc-home-title"),
          p(
            class = "bgc-home-subtitle",
            "A lightweight Shiny workspace for fast exploratory plotting, dimension reduction, statistics and data wrangling."
          )
        )
      ),
      tags$br(),
      fluidRow(
        valueBox(
          width = 3,
          value = n_core,
          subtitle = "Core Plot Modules",
          icon = icon("chart-line"),
          color = "info"
        ),
        valueBox(
          width = 3,
          value = n_advanced,
          subtitle = "Advanced Plot Modules",
          icon = icon("diagram-project"),
          color = "olive"
        ),
        valueBox(
          width = 3,
          value = n_statistics,
          subtitle = "Statistics Modules",
          icon = icon("calculator"),
          color = "warning"
        ),
        valueBox(
          width = 3,
          value = n_data_tools,
          subtitle = "Data Tools Modules",
          icon = icon("table"),
          color = "success"
        )
      ),
      tags$div(
        class = "row bgc-home-flex",
        box(
          width = 6,
          title = "Recommended Workflow",
          status = "primary",
          solidHeader = TRUE,
          collapsible = FALSE,
          closable = FALSE,
          headerBorder = TRUE,
          class = "bgc-home-box",
          tags$ol(
            style = "padding-left: 1.1rem; margin-bottom: 0; line-height: 1.9;",
            tags$li("Download an example table or upload your own data."),
            tags$li("Set variable names and visual parameters."),
            tags$li("Generate the static plot first."),
            tags$li("Open the interactive view only when needed."),
            tags$li("Export the plot, table, or processed dataset.")
          )
        ),
        box(
          width = 6,
          title = "What's Included",
          status = "secondary",
          solidHeader = TRUE,
          collapsible = FALSE,
          closable = FALSE,
          headerBorder = TRUE,
          class = "bgc-home-box",
          tags$ul(
            style = "padding-left: 1.1rem; margin-bottom: 0; line-height: 1.9;",
            tags$li(
              tags$b(paste0("Core Plots (", n_core, "): ")),
              "dot, bubble, bar, line, box, smooth, violin, pie, donut, density, histogram, ridgeline, lollipop, radar, heatmap, stacked area, waterfall, dumbbell."
            ),
            tags$li(
              tags$b(paste0("Advanced Plots (", n_advanced, "): ")),
              "PCA, PCoA, t-SNE, UMAP, RDA, volcano, correlation matrix, Sankey, treemap, dendrogram."
            ),
            tags$li(
              tags$b(paste0("Statistics (", n_statistics, "): ")),
              "t-test, ANOVA, correlation, linear & logistic regression, Wilcoxon, chi-square, Kruskal-Wallis, Fisher's exact, Shapiro-Wilk, post-hoc, survival, effect size."
            ),
            tags$li(
              tags$b(paste0("Data Tools (", n_data_tools, "): ")),
              "filter, select / rename, summarize, missing values, pivot, sort / distinct, mutate / cast, join, group & aggregate, export."
            )
          )
        )
      ),
      tags$div(
        class = "bgc-section-header",
        tags$h3("Explore Modules"),
        tags$p("Pick a category from the left sidebar to start.")
      ),
      tags$div(
        class = "row bgc-feature-row",
        feature_card(
          title = "Core Plots",
          count = n_core,
          description = "Exploratory chart library: dot, bar, line, box, violin, pie, histogram, heatmap and more.",
          icon_name = "chart-line",
          accent = "#17a2b8"
        ),
        feature_card(
          title = "Advanced Plots",
          count = n_advanced,
          description = "Dimension reduction and differential analysis: PCA, PCoA, t-SNE, UMAP, RDA, volcano, Sankey.",
          icon_name = "diagram-project",
          accent = "#74a63c"
        ),
        feature_card(
          title = "Statistics",
          count = n_statistics,
          description = "Hypothesis tests, regression, post-hoc, survival (KM), effect size — each with one-click run & export.",
          icon_name = "calculator",
          accent = "#f0a106"
        ),
        feature_card(
          title = "Data Tools",
          count = n_data_tools,
          description = "Tidy your data in-place: filter, select, summarize, pivot, mutate, join, aggregate, export.",
          icon_name = "table",
          accent = "#2ecc71"
        )
      ),
      tags$div(
        class = "bgc-section-header",
        tags$h3("Contact"),
        tags$p("Project status: actively simplified and maintained. Scan to connect.")
      ),
      tags$div(
        class = "row bgc-contact-row",
        tags$div(
          class = "col-sm-4 d-flex flex-column align-items-center bgc-contact-cell",
          img(src = "bgc-www/CloudChart_wechat.jpeg", width = "150px", class = "bgc-contact-img"),
          tags$div(class = "bgc-contact-label", "CloudChart WeChat")
        ),
        tags$div(
          class = "col-sm-4 d-flex flex-column align-items-center bgc-contact-cell",
          img(src = "bgc-www/liuyue_wechat.jpeg", width = "150px", class = "bgc-contact-img"),
          tags$div(class = "bgc-contact-label", "Author WeChat")
        ),
        tags$div(
          class = "col-sm-4 d-flex flex-column align-items-center bgc-contact-cell",
          img(src = "bgc-www/wechat_gongzhonghao.jpeg", width = "150px", class = "bgc-contact-img"),
          tags$div(class = "bgc-contact-label", "WeChat Channel")
        )
      ),
      tags$br()
    )
  )
}
