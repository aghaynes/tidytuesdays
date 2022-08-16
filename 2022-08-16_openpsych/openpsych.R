
characters <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-08-16/characters.csv')
library(tidyverse)

psych <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2022/2022-08-16/psych_stats.csv')

characters %>% 
  count(uni_name)

ad <- characters %>% 
  filter(uni_name == "Arrested Development") %>% 
  mutate(nth = str_remove(id, "AD"),
         nth = as.numeric(nth)) %>% 
  arrange(nth)

pers <- c("diligent", "workaholic", "slacker", "arrogant", "passive", 
          "weakass", "ambitious", "jaded")
ad_psych <- psych %>% 
  filter(char_id %in% ad$id) %>% 
  group_by(char_id) %>% #slice_head(n = 10)
  # mutate(personality = case_when(personality == "submissive")) %>% 
  filter(personality %in% pers) %>% 
  select(char_id, char_name, personality, avg_rating) %>% 
  pivot_wider(names_from = personality, values_from = avg_rating) %>% 
  mutate(across(where(is.numeric), .fns = ~ case_when(is.na(.x)  ~ 0,
                                   TRUE ~ .x))) %>% 
  pivot_longer(cols = 3:10, names_to = "personality", values_to = "avg_rating") %>% 
  arrange(personality) %>% ungroup() %>% #str
  left_join(ad %>% select(name, image_link) %>% rename(char_name = name))


jpeg(tf <- tempfile(fileext = ".jpeg"), 1000, 1000, bg = "transparent")
par(mar = rep(0,4), yaxs="i", xaxs="i", bg = "transparent")
plot(0, type = "n", ylim = c(0,1), xlim=c(0,1), axes=F, xlab=NA, ylab=NA, bg = "transparent")
plotrix::draw.circle(.5,0.5,.5, col="black")
dev.off()


walk(seq_along(ad$id), function(x) {
       fn <- file.path("2022-08-16_openpsych/", paste0("AD", x, ".jpg"))
       img <- image_read(fn)
       mask <- image_read(tf)
       mask <- image_scale(mask, as.character(image_info(img)$width))
       image_write(image_composite(mask, img, "plus"#, compose_args = "copy_opacity"
                                   ),
                   file.path("2022-08-16_openpsych/", paste0("AD", x, "_masked.jpg")))
})


library(patchwork)
library(geomtextpath)

lay <- "
AABC
DEFG
HIJK
"

pl <- map(unique(ad$id), ~
  ad_psych %>% 
    filter(char_id == .x) %>% 
    ggplot(aes(x = personality, y = avg_rating, 
               group = char_name, fill = personality)) +
    geom_bar(stat = "identity", show.legend = FALSE) +
    ylim(-40, 100) +
    # images cropped in inkscape
    ggimage::geom_image(image = file.path("2022-08-16_openpsych/", paste0(.x, "_mask2.png")), 
                        x = 1, y = -40, 
                        size = .3) +
    coord_curvedpolar() + theme_minimal() + 
    labs(title = ad$name[ad$id == .x]) +
    theme(axis.title = element_blank(),
          axis.text.y = element_blank(),
          axis.text.x = element_text(size = 4),
          title = element_text(size = 5),
          panel.grid = element_blank())
) 

adp <- ggplot(mtcars, aes(x = cyl, y = mpg)) +
  geom_point(col = NA) +
  # image from google
  ggimage::geom_image(image = file.path("2022-08-16_openpsych/index.png"), size = 1, y = 25, x = 6) +
  theme_minimal() + 
  geom_text(x = 6, y = 15, label = "Character traits") +
  theme(axis.title = element_blank(), axis.text = element_blank(),
        panel.grid = element_blank())

adp + pl[[1]] + pl[[2]] + pl[[3]] + pl[[4]] + pl[[5]] + pl[[6]] +
  pl[[7]] + pl[[8]] + pl[[9]] + pl[[10]] +
  plot_layout(design = lay) & theme(plot.margin = unit(c(0.1,0,0,0), "cm"))

ggsave(filename = file.path("2022-08-16_openpsych", "ad.png"), 
       width = 15, height = 10, units = "cm", dpi = 200)


