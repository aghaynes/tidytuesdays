


library(sf)
library(osmdata)
library(tidyverse)
library(raster)
library(ggnewscale)


xmin <- 0.7454377737107902
xmax <- 4.607851940802464
ymin <- 38.45325377315276
ymax <- 40.28275279143402
bbox <- st_polygon(list(matrix(c(xmin, ymin,
                    xmax, ymin,
                    xmax, ymax,
                    xmin, ymax,
                    xmin, ymin), ncol = 2, byrow = TRUE)))
bbox_sf <- st_sfc(bbox, crs = 4326)

# raster ----
raster <- elevatr::get_elev_raster(bbox_sf, 10)
rasmask <- raster::crop(raster, 
                        bbox_sf %>%
                          st_bbox() %>%
                          st_as_sfc() %>%
                          st_sf() %>%
                          st_cast() #%>%
                          # st_buffer(1)
                        ) 

rasmask <- aggregate(rasmask, 10)

rasmask_df <- rasmask %>%
  as.data.frame(xy = TRUE) 
names(rasmask_df)[3] <- "fill"

rasmask_df_water <- rasmask_df
rasmask_df_land <- rasmask_df
rasmask_df_water$fill[rasmask_df$fill > 0] <- NA
rasmask_df_land$fill[rasmask_df$fill < 0] <- NA

# borders ----
border <- rnaturalearth::ne_countries(returnclass = "sf", scale = 50)
border_crop <- border %>% 
  st_crop(bbox_sf)


mask <- st_difference(bbox_sf, border_crop) 
rasmask2 <- raster::mask(raster,
                         border_crop %>% 
                           st_bbox() %>%
                           st_as_sfc() %>%
                           st_sf() %>%
                           st_cast(), 
                         updatevalue = NA)


x <- opq(bbox = st_bbox(bbox_sf))
d <- x %>%
  add_osm_feature(key = 'highway') %>%
  osmdata_sf()

d2 <- d %>% `[[`("osm_lines") %>% 
  filter(highway %in% c("primary", "secondary"))



ggplot() + 
  geom_tile(data = rasmask_df_water, aes(x = x, y = y, fill = fill)) +
  # scale_fill_gradient(low = "grey10", high = "grey") +
  guides(fill = guide_none()) +
  new_scale_fill() +
  geom_contour(data = rasmask_df_water, 
               aes(x = x, y = y, z = fill), 
               col = "black", 
               size = .1) +
  geom_tile(data = rasmask_df_land, aes(x = x, y = y, fill = fill), na.rm = TRUE) +
  scale_fill_gradient2(mid = "#c2b280", high = "#004713", na.value = NA) +
  # geom_sf(data = border_crop, fill = NA) +
  geom_sf(data = d2, size = .1) +
  guides(fill = guide_none()) +
  theme_void() +
  theme(plot.margin = unit(c(0, -2, 0, 0), units = "cm")) +
  annotate("text", x = 0.7454377737107902, y = 40.22, 
           label = "Bathymetry around the Balearic Islands", 
           hjust = "left",
           col = "white", size = 3) +
  annotate("text", 
           x = 4.607851940802464,
           y = 38.46,
           label = "Viz: @aghaynes\nData: OSM, Natural Earth", 
           hjust = "right", 
           vjust = "bottom",
           size = 1.5, col = "white")

ggsave(here::here("30daymapchallenge",
                  "19_island", 
                  "fig.png"),
       height = 6,
       width = 10, units = "cm", dpi = 600)
