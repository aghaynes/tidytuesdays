

d <- readr::read_csv("OECDInflation.csv")

library(tidyverse)
library(geofacet)

d1 <- d %>%
  filter(Frequency == "Annual") %>%
  filter(Time == 2021) %>% #View()
  filter(MEASURE == "GY")
d2 <- d1 %>%
  group_by(Time) %>%
  summarise(Value = mean(Value, na.rm = TRUE)) %>%
  mutate(Country = "OECD")

d3 <- bind_rows(d1, d2) %>% #View()
  mutate(Country = fct_reorder(Country, Value),
         # name = Country,
         name = fct_rev(Country),
         col = ifelse(Country == "OECD", "orange", "yellow"))

d3 %>%
  # ggplot(aes(y = Value, x = Time, fill = col)) +
  ggplot(aes(y = Country, x = Value, fill = col)) +
  geom_bar(stat = "identity") +
  # geom_point() +
  # geom_line(aes(group = Country)) +
  theme_bw() +
  # facet_geo(~ name, grid = "world_countries_grid1") +
  # facet_wrap(~ Country) +
  labs(title = "Inflation in 2021 relative to 2020",
       caption = "Data: OECD, Graphic: @aghaynes") +
  guides(fill = guide_none()) +
  theme(axis.title = element_blank(),
        plot.title.position = "plot")

ggsave("18_OECD.png")
