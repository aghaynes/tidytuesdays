

library(tidyverse)
library(sf)

library(stars)
dem <- stars::read_stars(here::here("30daymapchallenge/data/NE1_50M_SR_W/NE1_50M_SR_W.tif"))

dat <- readr::read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/owid-covid-data.csv")

dat2 <- dat %>% 
  filter(!is.na(continent)) %>% 
  group_by(iso_code) %>% 
  mutate(max = max(date)) %>% 
  filter(date == max)


cou <- rnaturalearth::ne_countries(returnclass = "sf")


dat2$location[!dat2$location %in% cou$sovereignt]
cou$adm0_a3[!cou$adm0_a3 %in% dat2$location]
dat2[!dat2$iso_code %in% cou$iso_a3, c("iso_code", "location")]
cou[!cou$sovereignt %in% dat2$location, c("adm0_a3", "sovereignt")]

coudat <- cou %>%
  left_join(dat2, by = c("iso_a3" = "iso_code"))


coudat %>% 
  # st_transform(3857) %>% 
  # st_transform(4326) %>% 
  # st_transform(4055) %>%
  # st_transform(32610) %>%
  # st_transform("azequalarea") %>%
  # st_transform(4269) %>%
  st_transform("+proj=moll") %>%
  # st_wrap_dateline() %>% 
  ggplot() +
  geom_sf(aes(fill = total_deaths / 1e6), col = "black", lwd = .25) +
  # theme_void() +
  theme(legend.position = "bottom", 
        plot.title = element_text(hjust = .5, colour = "white"), 
        plot.subtitle = element_text(hjust = .5, colour = "white"), 
        plot.background = element_rect(fill = "grey20"),
        plot.caption = element_text(colour = "white"),
        panel.background = element_rect(fill = "grey20"), 
        legend.background = element_rect(fill = "grey20"),
        legend.title = element_text(colour = "white"),
        legend.text = element_text(colour = "white"),
        
        ) +
  guides(fill = guide_colorbar(title = "Millions of deaths", 
                               barwidth = 20,
                               title.position = "top")) +
  labs(title = glue::glue("{sprintf('%3.2f', sum(coudat$total_deaths, na.rm = TRUE)/1e6)}M deaths have been attributed to COVID-19"), 
       subtitle = glue::glue("up to {max(coudat$date, na.rm = TRUE)}"), 
       caption = "Data: OurWorldInData Viz: @aghaynes") +
  # scale_fill_continuous(breaks = seq(0, .8, .2)) +
  scale_fill_distiller(palette = 8, direction = 0, limits = c(0, .8)) 

ggsave(here::here("30daymapchallenge/03_polygon/fig.png"))

# coudat %>%
#   filter(continent.x == "Europe") %>% 
#   # st_transform(3857) %>% 
#   # st_transform(4326) %>% 
#   # st_transform(4055) %>%
#   # st_transform(32610) %>%
#   # st_transform("azequalarea") %>%
#   # st_transform(4269) %>%
#   st_transform("+proj=moll") %>%
#   # st_wrap_dateline() %>% 
#   ggplot() +
#   geom_sf(aes(fill = total_deaths_per_million)) +
#   theme_void() +
#   theme(legend.position = "bottom", 
#         plot.title = element_text(hjust = .5)) +
#   guides(fill = guide_colorbar(title = "", barwidth = 20)) +
#   labs(title = "Deaths attributed to COVID-19") +
#   scale_fill_fermenter(palette = 2, direction = 0)
  
# dat %>% 
#   filter(location == "Switzerland") %>% 
#   ggplot(aes(x = date, y = total_deaths_per_million)) +
#   geom_line()





  




