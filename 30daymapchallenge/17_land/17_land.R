





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

ggplot() +
  geom_tile(data = rasmask_df, mapping = aes(x = x, y = y, fill = fill), na.rm = TRUE) +
  geom_sf(data = uk, fill = NA) +
  geom_sf(data = d$osm_points, size = .5) +
  guides(fill = guide_none())



library(rayshader)



surface_matrix <- raster_to_matrix(rasmask)

zscale <- 22

surface_hillshade <- surface_matrix %>% 
  height_shade(
    texture = (grDevices::colorRampPalette(c(colorRampPalette(c("#132B43", "#56B1F7", "#6AA85B"))(9), "#D9CC9A", "#FFFFFF")))(256)
  ) %>% 
  add_shadow(texture_shade(surface_matrix, detail = 0.9, brightness = 15), 0.7) %>% 
  add_shadow(ray_shade(surface_matrix, 
                       sunangle = 180,
                       sunaltitude = 80, 
                       zscale = zscale, 
                       multicore = TRUE), 0) |> 
  add_shadow(ambient_shade(surface_matrix, zscale = zscale)) %>% 
  add_overlay(generate_point_overlay(heightmap = surface_matrix, 
                                     geometry = d$osm_points, 
                                     extent = raster::extent(rasmask),
                                     color = "red", size = .5))


plot_3d(surface_hillshade,
        asp = 2,
        surface_matrix,
        windowsize = c(800, 800), 
        waterdepth = 0, 
        wateralpha = .8,
        zscale = zscale,
        zoom = .4,
        solid = FALSE,
        theta = 25,
        phi = 40)

render_water(surface_matrix, zscale = zscale, wateralpha = .9)



render_snapshot(here::here("30daymapchallenge", "17_land", "fig.png"), 
                title_text = "Aeroways of the British Isles\nData: OSM, elevatr\nViz: @aghaynes", 
                title_size = 20)

render_highquality(here::here("30daymapchallenge", "17_land", "fig_hq.png"), 
                   title_text = "Aeroways of the British Isles\nData: OSM, elevatr\nViz: @aghaynes", 
                   title_size = 20)
  