


library(tidyverse)
library(patchwork)

slave_routes <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-06-16/slave_routes.csv')

d <- slave_routes %>% 
  mutate(decade = round(year_arrival / 10) * 10) %>% 
  group_by(decade) %>% 
  summarize(min = min(n_slaves_arrived, na.rm = TRUE),
            mean = mean(n_slaves_arrived, na.rm = TRUE),
            median = median(n_slaves_arrived, na.rm = TRUE),
            max = max(n_slaves_arrived, na.rm = TRUE),
            n_slaves_arrived = sum(n_slaves_arrived, na.rm = TRUE),
            ships = length(unique(ship_name))) 

f1 <- d %>% ggplot(aes(x = decade, xend = decade)) +
  geom_segment(aes(y = n_slaves_arrived, yend = 0))
  # geom_segment(aes(y = -ships, yend = 0))

f2 <- d %>% ggplot(aes(x = decade, xend = decade)) +
  geom_segment(aes(y = ships, yend = 0))


f1 / f2



d2 <- slave_routes %>% 
  group_by(ship_name) %>% 
  summarize(earliest = min(year_arrival, na.rm = TRUE),
            latest = max(year_arrival, na.rm = TRUE),
            n_slaves = sum(n_slaves_arrived, na.rm = TRUE),
            n = n(),
            mean = mean(n_slaves_arrived, na.rm = TRUE)) %>% 
  arrange(desc(n_slaves)) %>% 
  filter(!is.na(ship_name)) %>% 
  mutate(ship_name = factor(ship_name),
         ship_name = fct_reorder(ship_name, n_slaves))


d2 %>% 
  slice_head(n = 30) %>% 
  ggplot(aes(y = ship_name)) +
  geom_segment(aes(yend = ship_name,
                   x = earliest, xend = latest,
                   size = mean), show.legend = FALSE) +
  geom_point(aes(x = earliest,
                 size = mean), show.legend = FALSE) +
  geom_point(aes(x = latest,
                 size = mean), show.legend = FALSE) +
  geom_text(aes(x = 1895, label = round(mean)), size = 2, vjust = 0) +
  annotate("text", x = 1895, y = 31.5, label = "Average\nslaves", size = 2) +
  geom_text(aes(x = 1925, label = n), size = 2, vjust = 0) +
  annotate("text", x = 1925, y = 31.5, label = "Trips", size = 2) +
  labs(title = "The 30 ships that transported the most slaves",
       caption = "Line width is proportional to average number of slaves per trip\nData: SlaveVoyages.org; Viz: @aghaynes") +
  xlim(1500, 1930) +
  coord_cartesian(clip = 'off') +
  theme(
    axis.title = element_blank(),
    plot.title.position = "plot",
    plot.background = element_rect(fill = "#faebd7"), 
    panel.background = element_blank(), 
    panel.grid = element_blank(), 
    text = element_text(family = )
  )
ggsave("")
  