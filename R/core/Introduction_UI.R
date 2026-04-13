Introduction_UI <- function(id){
  tabItem(
    tabName = "introduction",
    fluidPage(
      fluidRow(
        # align = "center",
        column(width = 1),
        column(width = 10,
               includeMarkdown(bgc_project_path("CloudChart_Introduction.md"))),
        column(width = 1)
      ))
  )
}
