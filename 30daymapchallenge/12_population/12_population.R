library(tidyverse)
library(sf)

# UK ---- 
# cant find matches :(
# shp <- read_sf(here::here("30daymapchallenge", "data"), "LPA_MAY_2021_UK_BFC_V2")
# shp <- read_sf(here::here("30daymapchallenge", "data", "Data", "Polling Districts England", "Shape"), "polling_districts_England_region")
# 
# dat <- readxl::read_excel(here::here("30daymapchallenge", "data", "sape23dt8amid2020ward2020on2021lasyoaestimatesunformattedcorrection.xlsx"), 
#                           sheet = "Mid-2020 Persons", skip = 4)
# 
# names(dat)[5] <- "all"
# names(dat)[6:ncol(dat)] <- paste0("age_", names(dat)[6:ncol(dat)])
# 
# 
# shp_collapsed <- shp %>% group_by(Ward) %>% summarize()
# 
# 
# head(dat[,1:10], 5)
# head(shp)
# 
# 
# merged <- left_join(shp1, 
#                     dat, by = c("name" = "Name"))
# 
# shp1 <- shp
# st_geometry(shp) <- NULL
# shp %>% count(Ward) -> wards
# shpwards <- wards %>% mutate(Ward = trimws(stringr::str_remove(Ward, "Ward"))) %>% pull(Ward)
# table(wards %>% mutate(Ward = trimws(stringr::str_remove(Ward, "Ward"))) %>% pull(Ward) %in% wards$Ward)
# table(wards$Ward %in% shpwards)
# 
# 
# merged %>% 
#   ggplot() +
#   geom_sf(aes(fill = all))
# 
# 
# plot(merged)
# 
# 
# # rnaturalearth::ne_countries()

dat <- readxl::read_excel(here::here("30daymapchallenge", "data", "cc-d-01.02.02.03.xlsx"), 
                          sheet = 1, skip = 2)
names(dat)[1:2] <- c("gem", "total")
dat1 <- dat %>% mutate(gemnr = stringr::str_sub(gem, 1, 4),
                       gemnr = as.numeric(gemnr))

ch <- readr::read_csv2(here::here("30daymapchallenge", "data", "CH.csv"))
plz_gde <- ch %>% group_by(GDENR, DPLZ4) %>% count()


shp <- read_sf(here::here("30daymapchallenge", "data", "PLZO_SHP_LV95"), "PLZO_PLZ")
head(shp)
x <- shp %>% 
  left_join(plz_gde, c("PLZ" = "DPLZ4")) %>% 
  group_by(GDENR) %>% summarize() %>% st_cast() %>% 
  left_join(dat1, c("GDENR" = "gemnr")) %>% 
  filter(!is.na(GDENR)) %>% 
  st_transform(4326)


library(rayshader)

gg <- x %>% ggplot() + 
  geom_sf(aes(fill = log(total)), color = NA) +
  theme_void() +
  guides(fill = guide_none()) +
  scale_fill_viridis_c(
    option = "magma" #, limits = c(-40, 35), breaks = c(-40, -20, 0, 20, 35)
    # , na.value = ""
  ) +
  # labs(title = "Switzerland") +
  theme(title = element_text(angle = 35), 
        plot.title.position = "plot") +
  annotate("text", 6.3, 47, label = "Switzerlands population", angle = 35)
gg

ggsave(here::here("30daymapchallenge", "12_population", "fig.png"), height = 4, width = 7)


plot_gg(gg, scale = 10)

library(elevatr)

raster <- x %>% 
  get_elev_raster(5, )
ggplot() + geom_sf()
  
  
surface_matrix <- raster::crop(raster, x) %>% raster_to_matrix()
  
surface_hillshade <- surface_matrix %>% 
  height_shade(
    # texture = colorRampPalette(
    #   c("grey20", "white"), 
    #   bias = 1
    # )(255)
  ) %>% 
  add_overlay(generate_polygon_overlay(heightmap = surface_matrix,
                                       geometry = x %>% 
                                         dplyr::mutate(fill = cut(total, 
                                                                  seq(min(total, na.rm = TRUE), 
                                                                      max(total, na.rm = TRUE), 
                                                                      length.out = 101),
                                                                  labels = grey.colors(100, alpha = 1)),
                                                       fill = as.character(fill)
                                                       ),
                                       extent = raster::extent(raster),
                                       linecolor = "#00000000", data_column_fill = "fill"), 
              alphacolor = "grey")



plot_3d(surface_hillshade,
        surface_matrix,
        windowsize = c(800, 800),
        zscale = 150)
        