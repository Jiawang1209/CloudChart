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
          width = 4,
          valueBox(
            value = "17",
            subtitle = "Core Plot Modules",
            icon = icon("chart-line"),
            color = "info"
          )
        ),
        column(
          width = 4,
          valueBox(
            value = "7",
            subtitle = "Advanced Plot Modules",
            icon = icon("diagram-project"),
            color = "olive"
          )
        ),
        column(
          width = 4,
          valueBox(
            value = "CSV / TSV / XLSX",
            subtitle = "Supported Inputs",
            icon = icon("file-import"),
            color = "primary"
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
            title = "Current Focus",
            status = "secondary",
            solidHeader = TRUE,
            p("The current interface keeps only the core plotting modules online."),
            p("Unused and unfinished sections have been removed from the main workflow to improve startup speed and reduce page clutter.")
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
