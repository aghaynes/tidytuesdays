
tt <- tidytuesdayR::tt_load(2021, week = 16)

dat <- tt$post_offices



library(sf)
library(tidyverse)

sf <- dat %>% 
  filter(!is.na(longitude) & !is.na(latitude)) %>% 
  filter(longitude < 100) %>% 
  st_as_sf(coords = c("longitude", "latitude"))
st_crs(sf) <- 4326

ggplot(sf) +
  geom_sf()

sf3 <- dat %>% 
  filter(!is.na(longitude) & !is.na(latitude)) %>% 
  mutate(longitude = case_when(longitude > 0 ~ -longitude,
                               TRUE ~ longitude)) %>% 
  relocate(longitude, latitude) %>%
  usmap::usmap_transform() %>% 
  mutate(longitude.2 = longitude.1,
         latitude.2 = latitude.1) %>% 
  st_as_sf(coords = c("longitude.1", "latitude.1")) %>% 
  filter(longitude.2 > -4e6) %>% 
  filter(established > 1800) %>% 
  filter(established <= 1984 & (is.na(discontinued) | is.na(discontinued)))

ussf <- usmap::us_map()

usmap::plot_usmap() +
  geom_sf(data = sf3 %>% arrange(desc(established)), 
          mapping = aes(col = established), 
          size = .5) +
  scale_color_gradientn(colours = rainbow(5))

usmap::plot_usmap() +
  stat_summary_hex(data = sf3 %>% arrange(desc(established)), 
                   mapping = aes(x = longitude.2, 
                                 y = latitude.2, 
                                 z = established), 
                   fun = mean) +
  scale_fill_gradientn(colours = rainbow(5))


ussf2 <- ussf %>% 
  st_as_sf(coords = c("x", "y")) %>% 
  group_by(group, piece) %>% 
  arrange(order) %>% 
  summarize() %>% 
  st_cast("POLYGON") %>% 
  st_convex_hull()
ussf2 %>% 
  ggplot() +
  geom_sf()
