

library(stars)
library(ggplot2)
library(tidyverse)

library(osmdata)

ras <- read_stars("30daymapchallenge/23_GHSL/GHS_SMOD_POP2015_GLOBE_R2019A_54009_1K_V2_0.tif")

bb <- getbb("Switzerland", format_out = "sf_polygon")

xmin <- 5.922117750607918902
xmax <- 10.442991327965595
ymin <- 45.88702895178529
ymax <- 47.87295761842243
bbox <- st_polygon(list(matrix(c(xmin, ymin,
                                 xmax, ymin,
                                 xmax, ymax,
                                 xmin, ymax,
                                 xmin, ymin), ncol = 2, byrow = TRUE)))
bb <- st_sfc(bbox, crs = 4326)

ras2 <- ras %>% 
  st_crop(bb %>% st_transform(st_crs(ras))) #%>% 
  # mutate(across(everything(), as.factor))
write_stars(ras2, "30daymapchallenge/23_GHSL/tmp.tif")
ras3 <- read_stars("30daymapchallenge/23_GHSL/tmp.tif")

border <- rnaturalearth::ne_countries(returnclass = "sf", scale = 10)
border_crop <- border %>% 
  st_transform(st_crs(ras2)) %>% 
  st_crop(ras2)

ras3 <- ras2 %>% 
               mutate(across(everything(), as.factor)) %>% 
               st_transform(4326)
  
ggplot() +
  geom_stars(data = ras3) +
  # geom_sf(data = border_crop) +
  guides(fill = guide_none()) +
  theme_void() +
  theme(plot.title = element_text(hjust = .5, size = 60),
        plot.caption = element_text(hjust = .5, size = 30)) +
  scale_fill_manual(
    values = c(
      "lightblue","grey90", "grey80", "grey70", "grey60", "grey50", "grey40", "grey30", "grey20"
    )
  ) +
  # annotate("text", 150010, 4800000, 
  #          label = "Population density of the Balearic Islands", 
  #          angle = 45, size = 15) +
  labs(title = "Settlement of Switzerland", 
       caption = "viz: @aghaynes, data: Global Human Settlement Layer")
  # coord_equal() +
  # scale_fill_gradientn(colours = terrain.colors(20))

ggsave("30daymapchallenge/23_GHSL/fig.png", height = 10, width = 15, units = "cm", dpi = 400)
