homepage <- function(){
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
            width = "220px"
          ),
          tags$br(),
          h1("CloudChart"),
          p(
            style = "font-size: 18px; max-width: 880px; margin: 0 auto;",
            "A lightweight Shiny workspace for fast exploratory plotting in biogeochemistry, ecology and related data workflows."
          )
        )
      ),
      tags$br(),
      fluidRow(
        column(
          width = 3,
          valueBox(
            value = "17",
            subtitle = "Core Plot Modules",
            icon = icon("chart-line"),
            color = "info"
          )
        ),
        column(
          width = 3,
          valueBox(
            value = "7",
            subtitle = "Advanced Plot Modules",
            icon = icon("diagram-project"),
            color = "olive"
          )
        ),
        column(
          width = 3,
          valueBox(
            value = "9",
            subtitle = "Statistics Modules",
            icon = icon("calculator"),
            color = "warning"
          )
        ),
        column(
          width = 3,
          valueBox(
            value = "6",
            subtitle = "Data Tools Modules",
            icon = icon("table"),
            color = "success"
          )
        )
      ),
      fluidRow(
        column(
          width = 7,
          box(
            width = 12,
            title = "Recommended Workflow",
            status = "primary",
            solidHeader = TRUE,
            p("1. Download an example table or upload your own data."),
            p("2. Set variable names and visual parameters."),
            p("3. Generate the static plot first."),
            p("4. Open the interactive view only when needed.")
          )
        ),
        column(
          width = 5,
          box(
            width = 12,
            title = "What's Included",
            status = "secondary",
            solidHeader = TRUE,
            p(tags$b("Core Plots:"), " 17 ggplot2-based chart modules."),
            p(tags$b("Advanced Plots:"), " PCA, PCoA, t-SNE, UMAP, RDA, volcano, correlation matrix."),
            p(tags$b("Statistics:"), " t-test, ANOVA, correlation, linear regression, Wilcoxon, chi-square, Kruskal-Wallis, Fisher's exact, Shapiro-Wilk."),
            p(tags$b("Data Tools:"), " filter, select / rename, summarize, missing values, pivot, sort / distinct.")
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          align = "center",
          box(
            width = 12,
            title = "Preview",
            status = "info",
            solidHeader = TRUE,
            myCarousel_UI("myCarousel")
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          box(
            width = 12,
            title = "Contact",
            status = "secondary",
            solidHeader = TRUE,
            p("Project status: actively being simplified and maintained."),
            fluidRow(
              column(
                width = 4,
                align = "center",
                img(src = "bgc-www/CloudChart_wechat.jpeg", width = "180px")
              ),
              column(
                width = 4,
                align = "center",
                img(src = "bgc-www/liuyue_wechat.jpeg", width = "180px")
              ),
              column(
                width = 4,
                align = "center",
                img(src = "bgc-www/wechat_gongzhonghao.jpeg", width = "180px")
              )
            )
          )
        )
      )
    )
  )
}
