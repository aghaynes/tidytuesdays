
library(tidyverse)
library(sf)


dat <- readr::read_csv("https://github.com/jpatokal/openflights/raw/master/data/airports.dat",
                       col_names = c("a_id", "a_name", "a_city", "a_cou", "iata", 
                                     "icao", "lat", "long", "alt", "tz", "dst", "tz_db", "type", "src"))


rts <- readr::read_csv("https://github.com/jpatokal/openflights/raw/master/data/routes.dat", 
                       col_names = c("airline", "airline_id", "src", "src_id", "dest", "dest_id", 
                                     "code", "stops", "eqmt"))

dat_sf <- st_as_sf(dat, coords = c("long", "lat"), crs = 4326)

rts2 <- pivot_longer(rts %>% 
                       mutate(n = 1:n()) %>% 
                       select(n, src, dest), 
                     c("src", "dest")) 

options(dplyr.summarise.inform = FALSE, warn = 0 )

flights <- rts %>% 
  left_join(dat %>% 
              select(iata, lat, long) %>% 
              rename(src_lat = lat,
                     src_long = long), by = c("src" = "iata")) %>% 
  left_join(dat %>% 
              select(iata, lat, long) %>% 
              rename(dest_lat = lat,
                     dest_long = long), by = c("dest" = "iata")) %>% 
  filter(src != dest) %>% 
  # filter(src_long > -10 & src_long < 10 & dest_long > -10 & dest_long < 10) %>% 
  # filter(src_lat > 45 & src_lat < 55 & dest_lat > 45 & dest_lat < 55)
  filter(src %in% c("BSL", "MLH", "EAP", "GVA", "ZRH", "BRN"))
  
borders <- rnaturalearth::ne_countries(returnclass = "sf", scale = 10)


vert <- data.frame(x = c(20, 20, -20, -20, 20),
                    y = c(70, -70, -70, 70, 70))

horiz <- data.frame(x = c(70, 70, -70, -70, 70),
                    y = c(20, -20, -20, 20, 20))


ggplot() +
  geom_polygon(aes(x = x, y = y), vert, fill = "white") +
  geom_polygon(aes(x = x, y = y), horiz, fill = "white") +
  geom_sf(data = borders, 
          size = .1, 
          fill = "#00000020", 
          color = "#00000030") +
  # geom_sf(data = dat_sf, size = 1) +
  geom_curve(data = flights , 
             mapping = aes(x = src_long, 
                           y = src_lat, 
                           xend = dest_long, 
                           yend = dest_lat), 
             # col = "#ff000005") +
             col = "#00000020") +
  # coord_sf(xlim = c(-10, 10),
  #          ylim = c(45, 55)) +
  theme_void() +
  theme(plot.background = element_rect(fill = "#ff000020", color = NA)) +
  labs(title = paste(nrow(flights), "flights departing Switzerland"),
       caption = "Viz: @aghaynes; Data: OpenFlights")

ggsave("30daymapchallenge/20_movement/fig.png", height = 12, width = 22, units = "cm", dpi = 500)
