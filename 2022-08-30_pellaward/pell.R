
library(tidyverse)
pell <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-08-30/pell.csv')

d <- pell %>% 
  group_by(YEAR, STATE) %>% 
  summarize(award = sum(AWARD)) %>% 
  arrange(YEAR, desc(award)) %>% 
  mutate(rank = 1:n())

d %>% 
  ggplot(aes(x = YEAR, y = award)) +
  geom_point() +
  geom_line(aes(group = STATE, col = STATE))



library(ggbump)
library(ggtext)

remotes::install_github("thebioengineer/camcorder")
library(camcorder)

gg_record(
  dir = file.path("2022-08-30_pellaward","recording"), # where to save the recording
  device = "png", # device to use to save images
  width = 6, # width of saved image
  height = 4, # height of saved image
  units = "in", # units for width and height
  dpi = 300 # dpi to use when saving image
)

d %>% 
  filter(YEAR > 2004) %>%
  ggplot(aes(x = YEAR, y = rank)) +
  geom_bump(aes(group = STATE, col = STATE), size = 3.5, show.legend = FALSE) +
  geom_point(aes(col = STATE), size = 5, show.legend = FALSE) +
  geom_richtext(aes(x = 2018, y = rank, 
                    label = paste(STATE, "<br><span style='font-size:8pt'>", 
                                  round(award/1e6), "M</span>"), col = STATE), 
            data = d %>% filter(YEAR == 2017), show.legend = FALSE,
            lineheight = .1,
            fill = NA, label.color = NA, # remove background and outline
            ) +
  geom_richtext(aes(x = 2004, y = rank, 
                    label = paste("<span style='font-size:8pt'>", 
                                  round(award/1e6), "M</span>"), col = STATE), 
            data = d %>% filter(YEAR == 2005), show.legend = FALSE,
            lineheight = .1,
            fill = NA, label.color = NA, # remove background and outline
            ) +
  coord_cartesian(ylim = c(10, 1)) +
  labs(title = "California gives the most money in Pell awards ",
       x = "Year",
       caption = "Data: US Department of Education; Viz: @aghaynes"
       ) +
  scale_x_continuous(breaks = c(2005, 2009, 2013, 2017)) +
  theme(axis.title.y = element_blank(), 
        axis.text.y = element_blank(), 
        axis.ticks.y = element_blank())

ggsave(file.path("2022-08-30_pellaward", "pell.png"), 
       width = 6, # width of saved image
       height = 4, # height of saved image
       units = "in", # units for width and height
       dpi = 300 # dpi to use when saving image
       )

gg_playback(
  name = file.path("2022-08-30_pellaward","recording","pell_gif.gif"),
  first_image_duration = 8,
  last_image_duration = 12,
  frame_duration = .25
)
