rpython <- function(){
  tabItem(
    tabName = "rpython",
    header_tabItem(title = "Books of R and Python"),
    tags$hr(),
    fluidRow(
      align = "center",
      sortable(
        width = 4,
        p(class = "text-center", "R"),
        box(
          title = "No.1",
          width = 12,
          status = "info",
          solidHeader = TRUE,
          "R for Data Science",
          tags$br(),
          img(src = "R4DS.png", 
              width = "300px", 
              height = "420px", 
              onclick = "window.open('https://r4ds.had.co.nz/')")
        ),
        box(
          title = "No.2",
          width = 12,
          status = "info",
          solidHeader = TRUE,
          "Advance R",
          tags$br(),
          img(src = "Advance_R.png", 
              width = "300px", 
              height = "420px", 
              onclick = "window.open('https://adv-r.hadley.nz/')")
        ),
        box(
          title = "No.3",
          width = 12,
          status = "info",
          solidHeader = TRUE,
          "R Graphics Cookbook",
          tags$br(),
          img(src = "R_Graphics_Cookbook.jpeg", 
              width = "300px", 
              height = "420px", 
              onclick = "window.open('https://r-graphics.org/')")
        )
      ),
      sortable(
        width = 4,
        p(class = "text-center", "Python"),
        box(
          title = "No.4",
          width = 12,
          status = "warning",
          solidHeader = TRUE,
          "Python for Data Science",
          tags$br(),
          img(src = "Python_for_Data_Science.gif", 
              width = "300px", 
              height = "420px", 
              onclick = "window.open('https://pandas.pydata.org/pandas-docs/version/1.5.3/')")
        ),
        box(
          title = "No.5",
          width = 12,
          status = "warning",
          solidHeader = TRUE,
          "Python Data Science Handbook",
          tags$br(),
          img(src = "Python_Data_Science_Handbook.png", 
              width = "300px", 
              height = "420px", 
              onclick = "window.open('https://jakevdp.github.io/PythonDataScienceHandbook/')")
        ),
        box(
          title = "No.6",
          width = 12,
          status = "warning",
          solidHeader = TRUE,
          "Foundations for Analysis with Python",
          tags$br(),
          img(src = "Foundations_for_Analysis_with_Python.jpeg", 
              width = "300px", 
              height = "420px", 
              onclick = "window.open('https://github.com/cbrownley/foundations-for-analytics-with-python')")
        )
      ),
      sortable(
        width = 4,
        p(class = "text-center", "Mybook"),
        box(
          title = "No.7",
          width = 12,
          status = "success",
          solidHeader = TRUE,
          "No.7 information"        
          ),
        box(
          title = "No.8",
          width = 12,
          status = "success",
          color = "success",
          solidHeader = TRUE,
          "No.8 information"
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