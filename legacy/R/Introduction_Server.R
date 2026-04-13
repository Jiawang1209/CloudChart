# Legacy introduction server helper.
# The current app flow uses Introduction_UI directly from the shared factory.

Introduction_Server <- function(id){
  moduleServer(id, function(input, output, session){
    # 读取markdown文件
    markdown_file <- "./BCGViewer_Introduction.md"
    markdown_text <- readLines(markdown_file)
    
    # 渲染markdown
    output$introduction_markdown <- renderUI({
      HTML(markdownToHTML(markdown_text))
    })
  })
  
}
