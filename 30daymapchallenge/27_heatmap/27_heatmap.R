





library(osmdata)
library(sf)
library(tidyverse)
library(raster)

trace(grDevices::png, exit = quote({
  showtext::showtext_begin()
}), print = FALSE)

library(showtext)
font_add_google("Dancing Script", "Dancing Script")
font_families()

uk <- rnaturalearth::ne_countries(country = c("United Kingdom", "Ireland"), returnclass = "sf", scale = 50)

x <- opq(bbox = st_bbox(uk), timeout = 120)
d <- x %>%
  add_osm_feature(key = 'aeroway') %>%
  osmdata_sf()

raster <- elevatr::get_elev_raster(d$osm_points, 5)


rasmask <- raster::crop(raster, 
                        uk %>% 
                          st_bbox() %>% 
                          st_as_sfc() %>% 
                          st_sf() %>% 
                          st_cast() %>% 
                          st_buffer(1)) 

rasmask_df <- rasmask %>%
  as.data.frame(xy = TRUE) 
names(rasmask_df)[3] <- "fill"

library(ggnewscale)

p <- ggplot() +
  geom_tile(data = rasmask_df,
            mapping = aes(x = x, y = y, fill = fill),
            na.rm = TRUE) +
  guides(fill = guide_none()) +
  scale_fill_gradientn(colours = c("black", "white")) +
  geom_sf(data = uk, fill = NA) +
  geom_sf(data = d$osm_points, size = .5) +
  new_scale_fill() +
  stat_density_2d(data = d$osm_points %>%
                    st_coordinates() %>%
                    as.data.frame(),
                  aes(x = X, y = Y,
                      fill = ..level..),
                  geom = "polygon",
                  alpha = .5) +
  scale_fill_viridis_c(option = "A") +
  guides(fill = guide_none()) +
  annotate("text", x = -10, y = 60, 
           label = "Aeroways of the British Isles\nData: OSM, elevatr\nViz: @aghaynes",
           hjust = 0, size = 12, lineheight = .4) +
  theme(plot.margin = unit(c(-2,-3,-3,-1.5), "cm"))

ggsave("30daymapchallenge/27_heatmap/fig.png", p, 
       height = 15, 
       width = 10, 
       units = "cm", 
       dpi = 300)

