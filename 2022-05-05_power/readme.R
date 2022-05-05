

capacity <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-05-03/capacity.csv')
wind <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-05-03/wind.csv')
solar <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-05-03/solar.csv')
average_cost <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-05-03/average_cost.csv')


library(ggplot2)
library(tidyverse)
library(patchwork)

a <- ggplot(capacity, aes(x = year, y = total_gw, fill = type)) +
  geom_bar(stat = "identity") +
  labs(fill = "Energy\nsource",
       x = "Year",
       y = "Capacity (GW)")


bdat <- average_cost %>% 
  pivot_longer(2:4) %>% 
  mutate(nice_name = str_replace(name, "_mwh", ""),
         nice_name = str_to_title(nice_name)) 
b <- bdat %>% 
  ggplot(aes(x = year, y = value, col = nice_name)) +
  geom_line() +
  labs(col = "Energy\nsource",
       x = "Year",
       y = "Average $ per MWH")


c <- solar %>% 
  rename(mwh = solar_mwh,
         capacity = solar_capacity) %>% 
  mutate(type = "solar") %>% 
  bind_rows(
    wind %>% 
      rename(mwh = wind_mwh,
             capacity = wind_capacity) %>% 
      mutate(type = "wind")
  ) %>% 
  mutate(type = str_to_title(type)) %>% 
  ggplot(aes(x = date, y = mwh, col = type)) +
  geom_line() +
  geom_smooth() +
  labs(col = "Energy\nsource",
       y = "Projected $ per MWH",
       x = "Date")



a + (b / c) + 
  plot_annotation(caption = "Data: Berkeley Lab; Viz: @aghaynes", 
                  title = "US energy capacity and cost",
                  theme = theme(plot.title = element_text(hjust = 0.5)))

ggsave("2022-05-05_power/fig.png")

