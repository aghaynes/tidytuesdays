

library(sf)
library(tidyverse)
library(tmap)
library(ggtext)
countries <- rnaturalearth::ne_countries(returnclass = "sf")

flat <- countries %>% 
  # filter(str_detect(sovereignt, "[flat]"))
  filter(str_detect(sovereignt, "fl|la|at")) %>% 
  mutate(fl = str_detect(sovereignt, "fl"), 
         la = str_detect(sovereignt, "la"),
         at = str_detect(sovereignt, "at"),
         grp = case_when(fl ~ 1,
                         la ~ 2,
                         at ~ 3),
         grp = factor(grp, 1:3, c("fl", "la", "at"))
         )

bbox <- st_bbox(countries) %>% st_as_sfc()
st_crs(bbox) <- st_crs(countries)


# for(i in seq(-90, 90, 10)){
  lon <- 0
  lat <- 20
  crs <-paste0("+proj=laea +lat_0=", lat, " +lon_0=", lon," +x_0=3210000 +y_0=3210000 +ellps=GRS80 +units=m +no_defs ")
  countries_t <- st_transform(countries, crs)
  flat_t <- st_transform(flat, crs)
  bbox_t <- st_bbox(countries_t) %>% st_as_sfc(crs = st_crs(countries))
  
  sphere <- st_graticule(ndiscr = 10000, margin = 10e-6) %>%
    st_transform(crs = crs) %>%
    st_convex_hull() %>%
    summarise(geometry = st_union(geometry))
  graticule <- st_graticule(ndiscr = 10000, margin = 10e-6) %>%
    st_transform(crs = crs) 
  
  # tm_shape(sphere) + 
  #   tm_borders("skyblue") +
  #   tm_shape(countries_t) + 
  #   tm_borders() +
  #   tm_shape(flat_t) +
  #   tm_polygons(col = "blue") +
  #   tm_layout(bg.color = "black")

  ggplot() +
    # geom_sf(data = bbox_t, fill = "skyblue") +
    # geom_sf(data = sphere, fill = "skyblue") +
    # geom_sf(data = graticule, size = .1) +
    geom_sf(data = countries_t, size = .1, fill = "antiquewhite") +
    geom_sf(data = flat_t, aes(fill = grp), size = .1) +
    ggtitle("The 27 countries with parts of the word <i>flat</i>,<br><i style='color:#D55E00'>fl</i>, <i style='color:#0072B2'>la</i>, or <i style='color:#009E73'>at</i>, in their names") +
    scale_fill_manual(values = c(fl = "blue", la = "#0072B2", at = "#009E73"), drop=FALSE) +
    guides(fill = guide_none()) +
    theme(plot.title = element_markdown(hjust = .5)) +
    labs(caption = "Viz: @aghaynes; data: natural earth")
   ggsave("30daymapchallenge/28_notflat/fig.png", 
          dpi = 300, height = 15, width = 10, units = "cm")
# }



 