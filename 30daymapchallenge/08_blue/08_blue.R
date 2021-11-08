

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

raster <- elevatr::get_elev_raster(ch, z = 8)
ras <- mask(raster, ch) %>% 
  as.data.frame(xy = TRUE)
names(ras)[3] <- "fill"

area <- as.numeric(sum(st_area(water_polys2)))/1e6
dist <- as.numeric(sum(st_length(water_lines2)))/1000

blue <- "blue"

ggplot() +
  geom_tile(data = ras, mapping = aes(x = x, y = y, fill = fill)) +
  # geom_sf(data = ch) +
  geom_sf(data = water_lines2, col = blue, fill = blue, lwd = .5) +
  geom_sf(data = water_polys2, col = blue, fill = blue) +
  labs(title = paste0("Switzerlands ", round(area), " km<sup>2</sup> of lakes and ", round(dist), " km of rivers"),
       caption = "Viz: @aghaynes\nData: @swisstopo, DKM500 dataset") +
  theme(
    plot.background = element_rect(fill = "#bcf5f7"),
    panel.background = element_rect(fill = "#bcf5f7"),
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    plot.title = ggtext::element_markdown(hjust = .5, 
                                          size = 40), 
    plot.caption = element_text(size = 20, lineheight = .5)
  ) +
  coord_sf(x = st_bbox(ch)[c(1,3)],
           y = st_bbox(ch)[c(2,4)]) +
  scale_fill_gradient(na.value = NA, 
                      low = "#7cff69", 
                      high = "#094500",
                      guide = "none")
ggsave(here::here("30daymapchallenge", "08_blue", "fig.png"))


# create hex grid

initial <- ch
initial <- st_transform(initial, "+proj=robin +datum=WGS84")
initial$index <- 1:nrow(ch)
target <- st_geometry(initial)
ggplot(initial) +
  geom_sf()
grid <- st_make_grid(target,
                     cellsize = 20000, # take care with proj/CRS!
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


x <- st_intersection(water_lines2 %>% st_transform("+proj=robin +datum=WGS84"), 
                     grid_mask %>% 
                       sf:::select.sf(index) %>% 
                       mutate(hex_id = 1:n()),
                     # water_lines2 %>% st_transform("+proj=robin +datum=WGS84")
                     )


implode <- function(x, factor = 0.5) {
  vp <- magick::image_read(ggfx::get_viewport_area(x))
  # vp <- magick::image_flip(vp)
  # vp <- magick::image_flop(vp)
  vp <- magick::image_oilpaint(vp, 10)
  
  ggfx::set_viewport_area(x, as.raster(vp, native = TRUE))
}

hex <- x %>% 
  mutate(dist = st_length(.)) %>% 
  group_by(hex_id) %>% 
  summarize(n = n(), 
            dist = sum(as.numeric(dist))/1000) %>% 
  st_transform(st_crs(ch))

g <- grid_mask %>% 
  st_transform(st_crs(ch)) %>% 
  st_join(hex) %>% 
ggplot( 
  # aes(fill = n)
  
       # %>% st_transform("+proj=longlat +datum=WGS84")
) +
  # geom_tile(data = ras, mapping = aes(x = x, y = y, fill = fill)) +
  scale_fill_gradient(na.value = NA) +
  # ggfx::with_custom(
    geom_sf(aes(fill = dist), colour = NA) +
    # ,
    # implode    ) +
  coord_sf(x = st_bbox(ch)[c(1,3)],
           y = st_bbox(ch)[c(2,4)]) +
  labs("Length of water courses across Switzerland", 
       caption = "Viz: @aghaynes\nData: @SwissTOPO, DKM500") +
  theme(panel.background = element_rect(fill = NA),
        plot.background = element_rect(fill = NA),
        legend.position = "top",
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        legend.title = element_text(size = 50, lineheight = .5),
        legend.text = element_text(size = 30),
        legend.spacing.y = unit(.1, "cm"),
        plot.caption = element_text(size = 20, lineheight = .5)
        ) +
  guides(fill = guide_colorbar(barwidth = 40,
                               title = "Distance of rivers across Switzerland", 
                               title.position = "top", title.hjust = .5, ))

ggsave(here::here("30daymapchallenge", "08_blue", "fig2.png"), g) 
