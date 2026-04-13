China_Map <- function(){
  prov <- read_sf("./data/China_Map/china_full_map.json")
  
  ggplot(data = prov) + 
    geom_sf(aes(fill = NAME), color = "black", size = 0.01,
            show.legend = F) + 
    # geom_sf(data = subset(prov, NAME == "国界线" | NAME == "小地图框格"), 
    #         color = "black", size = 0.2) +
    annotation_north_arrow(location = "tr", which_north = "true",
                           pad_x = unit(0.75, "cm"),
                           pad_y = unit(0.5, "cm"),
                           style = north_arrow_fancy_orienteering(
                             line_col = "#be64ac",
                             text_col = "#5ac8c8",
                             fill = c("#be64ac", "#5ac8c8"),
                           ))+
    geom_sf_label(aes(label = NAME)) +
    theme_bw() +
    theme(axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          panel.grid = element_blank(),
          axis.text = element_blank(),
          axis.ticks = element_blank(),
          text = element_text(family = "STKaiti")
    ) +
    labs(title = "China Map",
         subtitle = "China Map",
         caption = "China Map")

}