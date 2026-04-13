library(hexSticker)
library(jpeg)

# sticker("./hexSticker_create_hexagon_sticker/photo.png",
#         package = "IAEViewer",
#         p_size = 20,
#         h_fill = "#a1d99b",
#         h_color = "#756bb1",
#         s_x = 1,
#         s_y = .5,
#         s_width = .6,
#         s_height = .2,
#         filename = "./hexSticker_create_hexagon_sticker/Sticker.png")


library(ggimage)
library(ggplot2)


bacteria_df <- data.frame(x = 0, y = 0, image = "./hexSticker_create_hexagon_sticker/microbiome.jpg")

ggplot(bacteria_df, aes(x = x, y = y)) +
  geom_image(aes(image = image),
             size = 1,
             by = "height") + 
  labs(x = "", y = "") + 
  theme_void() + 
  theme_transparent() -> p1


sticker(p1,
        # package = "IAEViewer",
        package = "BGCViewer",
        p_size = 20,
        s_x = 1,
        s_y = .85,
        h_fill = "white",
        h_color = "#756bb1",
        s_width = 1,
        s_height = 1,
        p_color = "#756bb1",
        filename = "./hexSticker_create_hexagon_sticker/tmp.png")


# img <- c("./hexSticker_create_hexagon_sticker/earth.jpeg",
#          "./hexSticker_create_hexagon_sticker/microbiome.jpg")

# two_df <- data.frame(x = 1:2,
#                      y = c(1,1),
#                      imag = img)
# 
# ggplot(two_df, aes(x = x, y = y)) +
#   geom_image(aes(image = img),
#              size = .6,
#              by = "height") + 
#   labs(x = "", y = "") + 
#   theme_void() + 
#   theme_transparent() -> p2
# 
# p2

earth_df <- data.frame(x = 0, y = 0, image = "./hexSticker_create_hexagon_sticker/earth.jpeg")
ggplot(earth_df, aes(x = x, y = y)) +
  geom_image(aes(image = image),
             size = 1,
             by = "height") + 
  labs(x = "", y = "") + 
  theme_void() + 
  theme_transparent() -> p2

p2

library(patchwork)

p2 + p1 -> p3



sticker(p3,
        # package = "IAEViewer",
        package = "BGCViewer",
        p_size = 15,
        s_x = 1,
        s_y = 1,
        h_fill = "#fa9fb5",
        h_color = "#756bb1",
        s_width = 1.85,
        s_height = 1,
        p_color = "#756bb1",
        p_y = 1.6,
        filename = "./hexSticker_create_hexagon_sticker/BGCViewer.png")

sticker(p3,
        package = "IAEViewer",
        p_size = 15,
        s_x = 1,
        s_y = 1,
        h_fill = "#fa9fb5",
        h_color = "#756bb1",
        s_width = 1.85,
        s_height = 1,
        p_color = "#756bb1",
        p_y = 1.6,
        filename = "./hexSticker_create_hexagon_sticker/p3.png")

# ggsave(filename = "./hexSticker_create_hexagon_sticker/20230223.pdf",
#        height = 5,
#        width = 5)
