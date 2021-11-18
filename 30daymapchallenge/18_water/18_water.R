

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


ch <- rnaturalearth::ne_countries(country = "Switzerland", returnclass = "sf", scale = 10)


water_lines <- st_read(here::here("30daymapchallenge", "data", "dkm500"), layer = "06_DKM500_GEWAESSER_LIN_ANNO") %>% 
  st_transform(st_crs(ch)) %>% 
  st_intersection(ch)
water_polys <- st_read(here::here("30daymapchallenge", "data", "dkm500"), layer = "07_DKM500_GEWAESSER_PLY_ANNO") %>% 
  st_transform(st_crs(ch)) %>% 
  st_intersection(ch)
water_polys2 <- st_read(here::here("30daymapchallenge", "data", "dkm500"), layer = "22_DKM500_GEWAESSER_PLY") %>% 
  st_transform(st_crs(ch)) %>% 
  st_intersection(ch)
water_lines2 <- st_read(here::here("30daymapchallenge", "data", "dkm500"), layer = "25_DKM500_GEWAESSER_LIN") %>% 
  st_transform(st_crs(ch)) %>% 
  st_intersection(ch)
# gb <- st_read(here::here("30daymapchallenge", "data", "dkm500"), layer = "24_DKM500_GRENZBAND")


vwss <- water_polys2[grepl("^Vier", water_polys2$NAMN1), ]
buff <- st_buffer(vwss , .1)


raster <- elevatr::get_elev_raster(buff, z = 8)
ras <- crop(raster, st_bbox(buff))
ras_df <- ras %>% as.data.frame(xy = TRUE)
names(ras)[3] <- "fill"



library(rayshader)
surface_matrix <- raster_to_matrix(ras)

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
  add_shadow(ambient_shade(surface_matrix, zscale = zscale)) #%>% 
  # add_overlay(generate_point_overlay(heightmap = surface_matrix, 
  #                                    geometry = d$osm_points, 
  #                                    extent = raster::extent(rasmask),
  #                                    color = "red", size = .5))


plot_3d(surface_hillshade,
        asp = 2,
        surface_matrix,
        windowsize = c(800, 800), 
        waterdepth = 0, 
        wateralpha = .8,
        zscale = zscale,
        zoom = .8,
        solid = FALSE,
        theta = 25,
        phi = 40)



library(rayvista)
library(rayshader)


zscale <- 15

for(theta in seq(0, 90, 1)){

  vista <- plot_3d_vista(46.98695691196451, 8.476016909445125, 
                         radius = 20000, 
                         elevation_detail = 12, 
                         zoom = .6, 
                         zscale = zscale, 
                         cache_dir = here::here("30daymapchallenge", "18_water", "cache"), 
                         theta = theta)
  
  render_label(heightmap = vista, 
               text='Luzern', 
               lat = 47.055429248956024,
               long = 8.306087404861996, 
               extent = attr(vista, 'extent'),
               altitude = 600,
               clear_previous = FALSE, 
               textcolor = "white",
               zscale = zscale)
  render_label(heightmap = vista, 
               text='Schwyz', 
               lat = 47.0184173206191,
               long = 8.648866164504023, 
               extent = attr(vista, 'extent'),
               altitude = 600,
               clear_previous = FALSE, 
               textcolor = "white",
               zscale = zscale)
  
  render_snapshot(filename = here::here("30daymapchallenge", "18_water", "cache", paste0("theta", theta, ".png")))
  rgl::clear3d() 
}



magick::image_write_gif(magick::image_read(here::here("30daymapchallenge", 
                                                      "18_water", 
                                                      "cache", 
                                                      paste0("theta", c(seq(0, 90, 1), seq(90, 0, -1)), ".png"))), 
                        path = here::here("30daymapchallenge", 
                                          "18_water", 
                                          "giffy.gif"), 
                        delay = 10/200)
