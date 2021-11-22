


borders <- rnaturalearth::ne_countries(continent = "Europe", returnclass = "sf", scale = 10)



library(sf)
library(tidyverse)
library(roughsf)

cols <- c("#8dd3c7",
"#ffffb3",
"#bebada",
"#fb8072",
"#80b1d3",
"#fdb462",
"#b3de69",
"#fccde5",
"#d9d9d9",
"#bc80bd",
"#ccebc5",
"#ffed6f")

xmin <- -2.2214980188385467
xmax <- -0.982789584587327
ymin <- 51.98679086431268
ymax <- 52.66327355170906
bbox <- st_polygon(list(matrix(c(xmin, ymin,
                                 xmax, ymin,
                                 xmax, ymax,
                                 xmin, ymax,
                                 xmin, ymin), ncol = 2, byrow = TRUE)))
bbox_sf <- st_sfc(bbox, crs = 4326)

ch <- rnaturalearth::ne_states(country = c("United Kingdom", "Ireland"), returnclass = "sf")
urban <- st_read("https://github.com/nvkelso/natural-earth-vector/raw/master/geojson/ne_50m_urban_areas.geojson")

ch2 <- ch %>% 
  st_intersection(bbox_sf) %>% 
  mutate(colx = sample(cols, nrow(.), replace = TRUE),
                     # color = colx, 
                     fill = colx,
                     hachureangle = sample(0:180, nrow(.), replace = TRUE),
                     stroke = .5) %>% 
  st_cast("POLYGON") 

urban2 <- urban %>% 
  st_intersection(bbox_sf)

cntr <- ch %>% 
  st_centroid() %>% 
  st_intersection(bbox_sf) %>% 
  mutate(label = name, 
         size = 0)

r <- roughsf(list(ch2 
             ,
             # urban2
             cntr), 
        roughness = 2, 
        bowing = 10, 
        simplification = 1,
        width = 800, 
        height = 1000, 
        font = "20px Palatino Linotype",
        caption = "Viz: @aghaynes",
        caption_font = "20px Palatino Linotype",
        title_font = "40px Palatino Linotype",
        title = "Counties around Warwickshire")

save_roughsf(r, here::here("30daymapchallenge", "22_boundary", "fig.png"))


