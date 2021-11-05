


library(osmdata)
library(sf)
library(tidyverse)

trace(grDevices::png, exit = quote({
  showtext::showtext_begin()
}), print = FALSE)

library(showtext)
font_add_google("Dancing Script", "Dancing Script")
font_families()


x <- opq(bbox = c(7.371655936571164, 46.9147458930287, 7.509008881506716, 47.005568969560066))
d <- x %>%
  add_osm_feature(key = 'amenity', value = "hospital") %>%
  osmdata_sf()
d2 <- x %>%
  add_osm_feature(key = 'amenity', value = "doctors") %>%
  osmdata_sf()
d3 <- x %>%
  add_osm_feature(key = 'amenity', value = "clinic") %>%
  osmdata_sf()
d4 <- x %>%
  add_osm_feature(key = 'highway', "residential") %>%
  osmdata_sf()
d5 <- x %>%
  add_osm_feature(key = 'boundary', "administrative") %>%
  osmdata_sf()
d6 <- x %>%
  add_osm_feature(key = 'water') %>%
  osmdata_sf()
d7 <- x %>%
  add_osm_feature(key = 'building') %>%
  osmdata_sf()



octo <- function(cp_x, cp_y, w, h){
  z <- function(x){ (z2(x) + x/sqrt(2)) }
  z2 <- function(x){ x / 2 }
  tribble(~x, ~y,
          cp_x - z2(w), cp_y - z(h),
          cp_x + z2(w), cp_y - z(h),
          cp_x + z(w), cp_y - z2(h),
          cp_x + z(w), cp_y + z2(h),
          cp_x + z2(w), cp_y + z(h),
          cp_x - z2(w), cp_y + z(h),
          cp_x - z(w), cp_y + z2(h),
          cp_x - z(w), cp_y - z2(h),
          cp_x - z2(w), cp_y - z(h)
  )
} 

oct <- list(octo(7.44, 46.9475, .02, .01) %>% 
  select(x,y) %>% 
  as.matrix) %>% 
  st_polygon(.data) %>%
  st_sfc(crs = st_crs(d5$osm_polygons))



ggplot() +
  # geom_sf(data = d4$osm_lines %>% st_intersection(oct), col = "grey") +
  geom_sf(data = d7$osm_polygons %>% st_intersection(oct), col = NA, fill = "grey") +
  # geom_sf(data = d$osm_polygons %>% st_intersection(oct)) +
  geom_sf(data = d2$osm_points %>% st_intersection(oct), col = "red") +
  geom_sf(data = d3$osm_points %>% st_intersection(oct), col = "blue") + 
  # geom_sf(data = d5$osm_lines %>% st_intersection(oct), col = "blue") +
  geom_sf(data = d6$osm_lines %>% st_intersection(oct), col = "skyblue") +
  geom_sf(data = d6$osm_polygons %>% st_intersection(oct), col = "skyblue", fill = "skyblue") +
  theme(
    panel.background = element_rect(fill = "transparent"),
    plot.background = element_rect(fill = "#faebd750"),
    axis.text = element_blank(),
    panel.grid = element_blank(),
    axis.ticks = element_blank(),
    plot.title = ggtext::element_markdown(hjust = .5, size = 50, family = "Dancing Script"),
    plot.caption = element_text(size = 20, lineheight = .5, family = "Dancing Script")
    ) +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_continuous(expand = c(0, 0)) +
  ggtitle("<span style='color:red;'>Doctors surgeries</span> and <span style='color:blue;'>Clinics</span> around Bern, Switzerland") +
  labs(caption = "Viz: @aghaynes\nData: OpenStreetMap")
  # geom_sf(data = oct) +
  # xlim(7.37, 7.5) +
  # ylim(46.91, 47.01)
  
ggsave(here::here("30daymapchallenge/05_osm/fig.png"))


