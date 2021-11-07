

library(tidyverse)
library(sf)

trace(grDevices::png, exit = quote({
  showtext::showtext_begin()
}), print = FALSE)

library(showtext)
font_add_google("Electrolize", "Electrolize")
font_families()

dat <- readr::read_csv(here::here("30daymapchallenge/data/windturbines.csv"))


dat2 <- dat %>% 
  mutate(state = str_extract(Place, "[:upper:]{2}"),
         state = case_when(
           !is.na(state) ~ state,
           str_detect(Place, "California") ~ "CA", 
           str_detect(Place, "New York") ~ "NY", 
           str_detect(Place, "Nebraska") ~ "NE", 
           str_detect(Place, "Columbia") ~ "CO", 
                           
                           ),
         capacity = str_remove_all(GeneratingCapacity, "[:upper:]"),
         capacity = trimws(capacity),
         capacity = as.numeric(capacity),
         ) %>% 
  group_by(state) %>% 
  summarize(capacity = sum(capacity, na.rm = TRUE),
            n = n())


# dat2$Place[is.na(dat2$state)]
# sort(unique(dat2$state))

library(rnaturalearth)

states <- ne_states(returnclass = "sf", 
                    country = "united states of america") 

sf <- full_join(states, dat2, by = c("postal" = "state"))

ggplot(sf) +
  geom_sf()


sf <- full_join(usa, dat2, by = c("postal" = "state"))

usa <- st_as_sf(maps::map("state", fill = TRUE, plot = FALSE, ))
ggplot(usa) +
  geom_sf()


us <- usmap::us_map(regions = "states") 
us2 <- us %>% 
  full_join(dat2, by = c("abbr" = "state")) #%>%
  # filter(!(is.na(x) | is.na(y))) %>% 
  # st_as_sf(coords=c("x","y")) %>% 
  # group_by(abbr) %>% 
  # arrange(order) %>% 
  # summarize(capacity = mean(capacity, na.rm = TRUE)) %>% 
  # st_cast("POLYGON") 
us2 %>% 
  mutate(capacity = capacity / 1000) %>% 
  ggplot(aes(x = x, y = y, group = group)) + 
  geom_polygon(aes(fill = capacity)) +
  coord_equal() +
  scale_fill_gradient(low = "#2eff64", 
                      high = "#005c18", 
                      na.value = "#94949450", 
                      limits = c(0, 30)) +
  labs(caption = "Viz: @aghaynes\nData: OpenEI.org",
       title = "Texas leads the way in wind power...", 
       subtitle = "according to OpenEI.org") +
  theme(plot.background = element_rect(fill = "#e7ffd9"),
        panel.background = element_rect(fill = "#e7ffd9"),
        legend.position = "bottom",
        legend.justification = "left",
        legend.box.background = element_rect(fill = "#e7ffd9", 
                                             colour = NA), 
        legend.background = element_rect(fill = "#e7ffd9", 
                                         colour = NA, ),
        legend.margin = margin(t = -.8, r = 0, b = -1, l = 0, unit = "cm"),
        legend.spacing.y = unit(.1, "cm"), 
        legend.text = element_text(size = 25),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank(),
        title = element_text(family = "Electrolize", hjust = .5, size = 35), 
        plot.caption = element_text(lineheight = .5) 
        ) +
  guides(fill = guide_colourbar(frame.colour = NA, 
                                title = "Capacity (MW)", 
                                title.position = "top", 
                                barwidth = 20)) 
ggsave(here::here("30daymapchallenge", "07_green", "fig.png"))


