
tt <- tidytuesdayR::tt_load(2021, week = 16)

dat <- tt$post_offices


trace(grDevices::png, exit = quote({
  showtext::showtext_begin()
}), print = FALSE)

library(sf)
library(tidyverse)
library(showtext)
font_add_google("Share", "Share")
font_families()



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

# usmap::plot_usmap(fill = NA, col = NA) +
ggplot(ussf) +
  stat_summary_hex(data = sf3 %>% 
                     arrange(desc(established)) %>% 
                     filter(!gnis_state %in% c("HI", "AK")), 
                   mapping = aes(x = longitude.2, 
                                 y = latitude.2, 
                                 z = established), 
                   fun = mean) +
  scale_fill_gradientn(colours = rainbow(5), breaks = seq(1840, 1960, 20)) +
  scale_color_continuous(breaks = seq(1800, 1984, 40)) +
  ggtitle("Average year of US post office opening") +
  labs(caption = "Viz: @aghaynes\nData: Blevins & Helbock, DOI: https://doi.org/10.7910/DVN/NUKCNA") +
  theme_void() +
  theme(legend.position = "bottom",
        plot.title = element_text(face = "bold", 
                                  family = "Share", 
                                  colour = "white", size = 50),
        plot.background = element_rect(fill = "grey20", colour = NA),
        panel.background = element_rect(fill = "grey20", colour = NA),
        legend.background = element_rect(fill = "grey20", colour = NA),
        legend.text = element_text(colour = "white", 
                                   family = "Share", size = 40),
        plot.caption = element_text(colour = "white", 
                                   family = "Share", size = 20, lineheight = .3),
        legend.title = element_blank()
        ) +
  guides(fill = guide_colorbar(title = "    Average opening year", 
                               title.position = "top", 
                               title.hjust = .5, 
                               barwidth = 20, 
                               direction = "horizontal"))

ggsave("30daymapchallenge/04_hex/fig.png")

# 
# ussf2 <- ussf %>% 
#   st_as_sf(coords = c("x", "y")) %>% 
#   group_by(group, piece) %>% 
#   arrange(order) %>% 
#   summarize() %>% 
#   st_cast("POLYGON") %>% 
#   st_convex_hull()
# ussf2 %>% 
#   ggplot() +
#   geom_sf()
