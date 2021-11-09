
library(sf)
library(tidyverse)



roads <- st_read(here::here("30daymapchallenge", "data", "dkm500"), layer = "21_DKM500_STRASSE")  
ch <- rnaturalearth::ne_countries(country = "Switzerland", returnclass = "sf", scale = 10)

robin_roads <- st_transform(roads, "+proj=robin +datum=WGS84")


initial <- st_transform(ch, "+proj=robin +datum=WGS84")
initial$index <- 1:nrow(ch)
target <- st_geometry(initial)
ggplot(initial) +
  geom_sf()
grid <- st_make_grid(target,
                     cellsize = 5000, # take care with proj/CRS!
                     crs = st_crs(initial),
                     what = "polygons",
                     square = FALSE # for hex, TRUE for squares
)
grid <- st_sf(index = 1:length(lengths(grid)), grid)
# cent_grid <- st_centroid(grid)
# cent_merge <- st_join(cent_grid, initial["index"], left = FALSE)
# grid_new <- inner_join(grid, st_drop_geometry(cent_merge))
grid_mask <- st_intersection(grid, initial)
ggplot(grid_mask 
       # %>% st_transform("+proj=longlat +datum=WGS84")
) +
  geom_sf()


x <- st_intersection(robin_roads, 
                     grid_mask %>% 
                       sf:::select.sf(index) %>% 
                       mutate(hex_id = 1:n()),
                     # water_lines2 %>% st_transform("+proj=robin +datum=WGS84")
)


hex <- x %>% 
  mutate(dist = st_length(.)) %>% 
  group_by(hex_id) %>% 
  summarize(n = n(), 
            dist = sum(as.numeric(dist))/1000) %>% 
  st_transform(st_crs(ch))

pdat <- grid_mask %>% 
  st_transform(st_crs(ch)) %>% 
  st_join(hex) %>% 
  mutate(col = "white") 

f <- pdat %>% 
  fortify()


p <- ggplot() +
  geom_sf(data = ch %>% 
            st_transform("+proj=robin +datum=WGS84")) +
  geom_sf(data = pdat
          , 
          aes(fill = dist), 
          lwd = 0, colour = scales::alpha("black", 0)
          ) +
  geom_sf(data = robin_roads %>% 
            st_intersection(ch %>% 
                              st_transform("+proj=robin +datum=WGS84"))) +
  scale_fill_gradient(low = "grey", high = "grey20", na.value = NA) +
  theme(panel.background = element_rect(fill = NA),
        plot.background = element_rect(fill = NA),
        legend.position = "top",
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        legend.title = element_text(size = 50, lineheight = .5),
        legend.text = element_text(size = 30),
        legend.spacing.y = unit(.1, "cm"),
        plot.caption = element_text(size = 7, lineheight = 1), 
        title = element_text(hjust = .5)
  ) +
  guides(fill = guide_none()) +
  labs(title = "Density of the Swiss road network", 
       caption = "Viz: @aghaynes\nData: @SwissTOPO, DKM500")


ggsave(here::here("30daymapchallenge", "09_monochrome", "fig.png"), p, height = 10, width = 15, units = "cm")









