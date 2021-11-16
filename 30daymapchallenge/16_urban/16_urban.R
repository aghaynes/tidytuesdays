

library(sf)
library(tidyverse)
library(patchwork)
library(terra)


urban <- st_read("https://github.com/nvkelso/natural-earth-vector/raw/master/geojson/ne_50m_urban_areas.geojson")
cou <- rnaturalearth::ne_countries(return = "sf")
ras <- terra::rast("https://github.com/nvkelso/natural-earth-raster/raw/master/50m_rasters/GRAY_50M_SR_OB/GRAY_50M_SR_OB.tif")

sf_proj_info()


lapply(c("moll", "wag1", "ortel", "bacon", "boggs", "adams_ws1", "utm", "tcc", "healpix"), 
       function(x){
         urban %>% 
           st_transform(paste0("+proj=", x)) %>% 
           ggplot() +
           geom_sf(data = cou, fill = "black") +
           geom_sf() 
         
       }) %>% wrap_plots()

crs(ras) <- "+proj=lonlat"
ras2 <- aggregate(ras, 10)
rasdf <- ras2 %>% as.data.frame(xy = TRUE)

urban %>% 
  # st_transform("+proj=ortel") %>%
  ggplot() +
  geom_raster(data = rasdf, aes(x = x, y = y, fill = GRAY_50M_SR_OB)) +
  # ggspatial::layer_spatial(data = ras, aes(fill = GRAY_50M_SR_OB)) +
  geom_sf(data = cou, fill = "black", col = "black") +
  geom_sf(fill = "yellow", col = "yellow") +
  # ggshadow::geom_glowpoint(aes(geometry = geometry), 
  #                               fill = "yellow", col = "yellow") +
  guides(fill = guide_none()) +
  scale_fill_gradient(low = "grey", high = "grey10") +
  # labs(caption = "Data: Natural Earth  Viz: @aghaynes") +
  theme(
    plot.background = element_rect("grey20"),
    panel.background = element_blank(),
    # plot.margin = margin(-1,-1,-1,-1, "cm"),
    plot.margin = unit(c(-3,-1.5,-3,-1.5), "cm"),
    axis.text = element_blank(),
    axis.title = element_blank()
  ) +
  annotate("text", x = 175, y = -85, 
           label = "Viz: @aghaynes  Data: Natural Earth",
           hjust = "right", vjust = "center", size = 3,
           col = "white") +
  annotate("text", x = -170, y = 0,
           label = "Urban areas of the World", col = "yellow",
           angle = 90, hjust = "center", vjust = "center", size = 10)
ggsave(here::here("30daymapchallenge", "16_urban", "fig.png"))























