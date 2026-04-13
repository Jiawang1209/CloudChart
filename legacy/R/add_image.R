add_image <- function(){
  tagList(
    output$wechat_liuyue <- renderImage({
      list(
        src = "./data/image/liuyue_wechat.jpeg",
        contentType = "ipeg",
        width = 300,
        height = 400
      )
    }, deleteFile = F),
    
    output$image_develper_7 <- renderImage({
      list(
        src = "./data/image/liyanzhuo_photo.jpeg",
        contentType = "ipeg",
        width = 210,
        height = 300
      )
    }, deleteFile = F),
    
    output$image_develper_8 <- renderImage({
      list(
        src = "./data/image/chenjianhao_photo.jpeg",
        contentType = "ipeg",
        width = 225,
        height = 300
      )
    }, deleteFile = F)
  )
}