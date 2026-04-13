myCarousel_UI <- function(id){
  slickR::slickROutput(NS(id, "myCarousel"), width = "50%", height = "250px")
}

myCarousel_Server <- function(id){
  moduleServer(id, function(input, output, session){
    # the position of local image
    img_paths <- c(
      bgc_project_path("data", "image", "chenjianhao_photo.jpeg"),
      bgc_project_path("data", "image", "liuyue_wechat.jpeg"),
      bgc_project_path("data", "image", "liyanzhuo_photo.jpeg"),
      bgc_project_path("hexSticker_create_hexagon_sticker", "IAEViewer.png")
    )
    
    # local image trans to HTML Tag
    img_tags <- lapply(img_paths, function(x) {
      img_base64 <- base64enc::dataURI(file = x)
      tags$img(src = img_base64, width = "30%", height = "200px")
    })
    
    # use slickR function to create Carousel
    output$myCarousel <- slickR::renderSlickR({
      slickR::slickR(img_tags, width = "30%", height = "200px") + 
        slickR::settings(
          autoplay = TRUE, # 自动播放
          autoplaySpeed = 1000,# 每张图片停留的时间（毫秒）
          slidesToShow=2
        )
    })
  })
}
