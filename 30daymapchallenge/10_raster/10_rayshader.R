library(raster)
library(rayshader)
library(terrainr)
library(sf)
library(elevatr)


location <- tmaptools::geocode_OSM("Bern")
location <- st_as_sf(as.data.frame(t(as.data.frame(location$coords))), coords = c("x", "y"), crs = 4326)
buff <- st_buffer(location, .1)
zscale <- 1
raster <- set_bbox_side_length(
  location,
  15000
) |> 
  # get_tiles(resolution = zscale) |> 
  get_elev_raster(12, )
  # merge_rasters() |> 
  # raster()

raster2 <- crop(raster, buff)

surface_matrix <- raster_to_matrix(raster2)
# surface_matrix <- surface_matrix[1:800, 1:800]

# color_pal <- function(n = 255, bias = 1) {
#   pal <- colorRampPalette(
#     c("black", "white"),
#     bias = bias
#   )
#   return(pal(n))
# }

surface_hillshade <- surface_matrix %>% 
  height_shade(
    # texture = colorRampPalette(
    #   c("grey20", "white"), 
    #   bias = 1
    # )(255)
    ) %>% 
  add_shadow(texture_shade(surface_matrix, detail = 0.9, brightness = 15), 0.7) %>% 
  add_shadow(ray_shade(surface_matrix, 
                       sunangle = 180,
                       sunaltitude = 80, 
                       zscale = zscale, 
                       multicore = TRUE), 0) |> 
  add_shadow(ambient_shade(surface_matrix, zscale = zscale)) %>% 
  # add_water(detect_water(surface_matrix, zscale = zscale, min_area = 10, max_height = 500)) %>% 
  add_overlay(generate_point_overlay(heightmap = surface_matrix, 
                                     geometry = location, 
                                     extent = raster::extent(raster2),
                                     color = "red", 
                                     size = 3)) #%>% 
  # add_overlay(generate_polygon_overlay(heightmap = surface_matrix, 
  #                                      geometry = buff %>% dplyr::mutate(fill = "#00000000"), 
  #                                      extent = raster::extent(raster2),
  #                                      linecolor = "pink", data_column_fill = "fill"))

plot_3d(surface_hillshade,
        surface_matrix,
        windowsize = c(800, 800),
        zscale = 10,
        # zoom = 0.5,
        solid = FALSE,
        theta = 0,
        phi = 90)

# render_highquality(here::here("30daymapchallenge", "10_raster", "fig.png"))

png(here::here("30daymapchallenge", "10_raster", "fig.png"), width = 10, height = 10, units = "cm", res = 300)
plot_map(surface_hillshade,
         surface_matrix, )
dev.off()

render_highquality(here::here("30daymapchallenge", 
                              "10_raster", 
                              "rayshader.png"), 
                   lightintensity = 1000, parallel = TRUE)






# mat <- matrix(c(
#   1, 1, 1, 1, 1,
#   3, 3, 3, 3, 3,
#   1, 2, 3, 2, 1,
#   2, 3, 4, 3, 3,
#   3, 4, 7, 4, 5, 
#   1, 1, 1, 1, 1), byrow = TRUE, nrow = 6)
# mat
# 
# mat2 <- matrix(c(
#   0, 0, 0, 0, 0,
#   0, 0, 0, 0, 0,
#   0, 0, 0, 0, 0,
#   0, 0, 8, 0, 0,
#   0, 0, 0, 0, 0, 
#   0, 0, 0, 0, 0), byrow = TRUE, nrow = 6)
# 
# surface <- mat %>% 
#   height_shade() %>% 
#   add_overlay(mat2 %>% height_shade(), alphacolor = "red") %>% 
#   add_shadow(texture_shade(mat, detail = 1, ), ) %>% 
#   add_shadow(ray_shade(mat, 
#                        sunaltitutde = 45, # angle above horizon
#                        sunangle = 315,    # angle relative to matrix of the sun (default = 315 = top right)
#                        zscale = 1), 0) %>% 
#   add_shadow(ambient_shade(mat)) 
# 
# plot_3d(surface, mat)
