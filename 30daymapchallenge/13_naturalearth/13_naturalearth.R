library(sf)



# files <- c("L_0", 
#            "K_200", 
#            "J_1000", 
#            "I_2000", 
#            "H_3000", 
#            "G_4000", 
#            "F_5000", 
#            "E_6000", 
#            "D_7000", 
#            "F_5000", 
#            "E_6000", 
#            "D_7000", 
#            "C_8000", 
#            "B_9000", 
#            "A_10000" 
#            )
# 
# bathy <- lapply(files, function(x)
#                   st_read(paste0("https://github.com/nvkelso/natural-earth-vector/raw/master/geojson/ne_10m_bathymetry_"
#                           , x, ".geojson"))
#                 )

library(tidyverse)

# ggplot() +
#   purrr::map(bathy, ~ geom_sf(data = .x))
# 
# bathy[[1]] %>% ggplot() + geom_sf()
# bathy[[2]] %>% ggplot() + geom_sf()
# bathy[[3]] %>% ggplot() + geom_sf()
# bathy[[4]] %>% ggplot() + geom_sf()
# bathy[[5]] %>% ggplot() + geom_sf()
# bathy[[2]] %>% st_crs()

popplaces <- st_read("https://github.com/nvkelso/natural-earth-vector/raw/master/geojson/ne_50m_populated_places.geojson")
cou <- rnaturalearth::ne_coastline(, return = "sf")

crs_goode <- "+proj=igh"






cou %>% 
  st_transform(crs_goode) %>% 
  ggplot() +
  geom_sf() +
  geom_sf(data = popplaces %>% 
            st_transform(crs_goode))

world <- st_as_sf(rworldmap::getMap(resolution = "low"))




## projection outline in long-lat coordinates
lats <- c(
  90:-90, # right side down
  -90:0, 0:-90, # third cut bottom
  -90:0, 0:-90, # second cut bottom
  -90:0, 0:-90, # first cut bottom
  -90:90, # left side up
  90:0, 0:90, # cut top
  90 # close
)
longs <- c(
  rep(180, 181), # right side down
  rep(c(80.01, 79.99), each = 91), # third cut bottom
  rep(c(-19.99, -20.01), each = 91), # second cut bottom
  rep(c(-99.99, -100.01), each = 91), # first cut bottom
  rep(-180, 181), # left side up
  rep(c(-40.01, -39.99), each = 91), # cut top
  180 # close
)
goode_outline <- 
  list(cbind(longs, lats)) %>%
  st_polygon() %>%
  st_sfc(
    crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"
  ) %>% 
  st_transform(crs = crs_goode)
## bounding box in transformed coordinates
xlim <- c(-21945470, 21963330)
ylim <- c(-9538022, 9266738)
goode_bbox <- 
  list(
    cbind(
      c(xlim[1], xlim[2], xlim[2], xlim[1], xlim[1]), 
      c(ylim[1], ylim[1], ylim[2]+1000, ylim[2]+1000, ylim[1])
    )
  ) %>%
  st_polygon() %>%
  st_sfc(crs = crs_goode)
## area outside the earth outline
goode_mask <- st_difference(goode_bbox, goode_outline)

greycol <- "grey80"

ggplot() + 
  geom_sf(data = goode_bbox, col = NA, fill = "lightblue") +
  geom_sf(data = world %>% st_transform(crs_goode),
          fill = "black", col = "grey", size = .1) +
  geom_sf(data = goode_mask, col = NA, fill = "grey80") +
  geom_sf(data = goode_outline, fill = NA) +
  geom_sf(data = popplaces %>% 
            filter(FEATURECLA == "Admin-0 capital") %>% 
            st_transform(crs_goode),
          # aes(size = MIN_AREAKM),
          col = "white") +
  geom_sf(data = popplaces %>% 
            filter(FEATURECLA == "Admin-0 capital") %>% 
            st_transform(crs_goode),
          # aes(size = MIN_AREAKM),
          fill = NA, pch = 21) +
  coord_sf(xlim = c(-19000000, 19000000)) +
  # scale_x_continuous(name = NULL, breaks = seq(-120, 120, by = 60)) +
  # scale_y_continuous(name = NULL, breaks = seq(-60, 60, by = 30)) +
  theme(panel.background = element_rect(fill = "grey80"),
        plot.background = element_rect(fill = "grey80"),
        panel.grid = element_blank(),
        # panel.grid.major = element_line(color = "black", 
        #                                 size = 0.1),
        # panel.grid.minor = element_line(color = "black", 
        #                                 size = 0.1),
        plot.margin = unit(c(0,0,0,0), "cm"), 
        plot.title.position = "plot", 
        plot.title = element_text(hjust = .5), 
        axis.title = element_blank(), 
        legend.position = c(.5, .05), 
        legend.direction = "horizontal", 
        legend.background = element_blank(), 
        legend.key = element_blank()) +
  # guides(size = guide_legend(title = "KM", )) +
  annotate("text", x = 0, y = 9377738, 
           label = "Capital Cities of the World", 
           fontface = 2) +
  annotate("text", x = 20500000, y = -9538022, 
           label = "Viz: @aghaynes\nData: Natural Earth",
           hjust = "right", vjust = "center", size = 2)
  # labs(caption = "Data: Natural Earth\nViz: @aghaynes")
  # facet_wrap( ~ FEATURECLA, ncol = 1)


ggsave(here::here("30daymapchallenge/13_naturalearth", "fig.png"), 
       width = 20, height = 10, units = "cm", 
       # device = cairo_pdf
       )



ggplot() + 
  geom_sf(data = goode_bbox, col = NA, fill = "lightblue") +
  geom_sf(data = world %>% st_transform(crs_goode),
          fill = "black", col = "grey", size = .1) +
  geom_sf(data = goode_mask, col = NA, fill = "grey80") +
  geom_sf(data = goode_outline, fill = NA) +
  geom_sf(data = popplaces %>% 
            filter(FEATURECLA == "Admin-0 capital") %>% 
            filter(grepl("Europe", .$TIMEZONE)) %>% 
            st_transform(crs_goode),
          # aes(size = MIN_AREAKM),
          col = "white") +
  geom_sf(data = popplaces %>% 
            filter(FEATURECLA == "Admin-0 capital") %>% 
            filter(grepl("Europe", .$TIMEZONE)) %>% 
            st_transform(crs_goode),
          # aes(size = MIN_AREAKM),
          fill = NA, pch = 21) +
  coord_sf(xlim = c(0, 4000000), ylim = c(3867738, 7067738)) +
  # scale_x_continuous(name = NULL, breaks = seq(-120, 120, by = 60)) +
  # scale_y_continuous(name = NULL, breaks = seq(-60, 60, by = 30)) +
  theme(panel.background = element_rect(fill = "grey80"),
        plot.background = element_rect(fill = "grey80"),
        panel.grid = element_blank(),
        # panel.grid.major = element_line(color = "black", 
        #                                 size = 0.1),
        # panel.grid.minor = element_line(color = "black", 
        #                                 size = 0.1),
        plot.margin = unit(c(.25,0,.25,0), "cm"),
        plot.title.position = "plot", 
        plot.title = element_text(hjust = .5), 
        axis.title = element_blank(), 
        # legend.position = c(.5, .05), 
        legend.position = "bottom",
        legend.direction = "horizontal", 
        legend.background = element_blank(), 
        legend.key = element_blank(),
        # legend.title=element_blank(),
        legend.margin = margin(c(-10, -10, -20, 0)),
        legend.spacing.y = unit(.1, "cm"),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        plot.caption = element_text(size = 5)) +
  # guides(size = guide_legend(title = "KM", )) +
  annotate("text", x = 0, y = 9377738, 
           label = "Capitol Cities of the World", 
           fontface = 2) +
  annotate("text", x = 20500000, y = -9538022, 
           label = "Viz: @aghaynes  Data: Natural Earth",
           hjust = "right", vjust = "center", size = 2) +
  ggtitle("Capital Cities of Europe") +
  labs(caption = "Viz: @aghaynes  Data: Natural Earth")
# facet_wrap( ~ FEATURECLA, ncol = 1)

ggsave(here::here("30daymapchallenge/13_naturalearth", "figEU.png"), 
       width = 10, height = 10, units = "cm", 
       # device = cairo_pdf
)
