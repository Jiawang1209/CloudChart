developer <- function(){
  tabItem(
    tabName = "developer",
    header_tabItem(title = "BGCViewer developer information"),
    tags$hr(),
    fluidRow(
      align = "center",
      sortable(
        width = 4,
        p(class = "text-center", "Group1"),
        box(
          title = "No.1",
          width = 12,
          status = "info",
          solidHeader = TRUE,
          "王 超",
          tags$br(),
          "课题组组长",
          tags$br(),
          img(src = "wangchao.jpeg", 
              width = "300px", 
              height = "420px")
        ),
        box(
          title = "No.2",
          width = 12,
          status = "info",
          solidHeader = TRUE,
          "姜 萍",
          tags$br(),
          "高级工程师",
          tags$br(),
          img(src = "jiangping.png", 
              width = "300px", 
              height = "420px")
        ),
        box(
          title = "No.3",
          width = 12,
          status = "info",
          solidHeader = TRUE,
          "刘 玥",
          tags$br(),
          "特别研究助理",
          tags$br(),
          img(src = "liuyue.jpeg", 
              width = "300px", 
              height = "420px")
        )
      ),
      sortable(
        width = 4,
        p(class = "text-center", "Group2"),
        box(
          title = "No.4",
          width = 12,
          status = "warning",
          solidHeader = TRUE,
          "No.4 information"
        ),
        box(
          title = "No.5",
          width = 12,
          status = "warning",
          solidHeader = TRUE,
          "No.5 information"
        ),
        box(
          title = "No.6",
          width = 12,
          status = "warning",
          solidHeader = TRUE,
          "No.6 information"
        )
      ),
      sortable(
        width = 4,
        p(class = "text-center", "Group3"),
        box(
          title = "No.7",
          width = 12,
          status = "success",
          solidHeader = TRUE,
          "李彦卓",
          tags$br(),
          "武汉大学研究生",
          tags$br(),
          img(src = "liyanzhuo_photo.jpeg", 
              width = "300px", 
              height = "430px")
        ),
        box(
          title = "No.8",
          width = 12,
          status = "success",
          color = "success",
          solidHeader = TRUE,
          "陈建豪",
          tags$br(),
          "武汉大学研究生",
          tags$br(),
          img(src = "chenjianhao_photo.jpeg", 
              width = "300px", 
              height = "420px")
        ),
        box(
          title = "No.9",
          width = 12,
          status = "success",
          color = "success",
          solidHeader = TRUE,
          "No.9 information"
        )
      )
    )
  )
}