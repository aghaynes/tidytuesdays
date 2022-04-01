


library(treemapify)

df <- data.frame(vax = c("none", "single", "full", "booster"),
                 grp = c("Unvaccinated (34.9%)", "Vaccinated (65.1%)", "Vaccinated (65.1%)", "Vaccinated (65.1%)"),
                 val = c(100-65.1, 65.1-58.3, 58.3-21.1, 21.1),
                 txt = factor(c("", "Single (6.8%)",
                                "Full (37.2%)", "Booster (21.1%)"),
                              levels = c("", "Single (6.8%)",
                                         "Full (37.2%)", "Booster (21.1%)")))

ggplot(df, aes(area = val, fill = vax, subgroup = grp, label = txt)) +
  geom_treemap(
    layout = "fixed"
    ) +
  geom_treemap_subgroup_border(
    layout = "fixed"
    ) +
  geom_treemap_text(
    layout = "fixed",
    size = 10,
    # family = "EmojiOne"
    ) +
  geom_treemap_subgroup_text(
    layout = "fixed",
    place = "middle",
    colour = c("black", "black", "black", "black"),
    size = 13,
    alpha = c(.6, .3, .3, .3)
    ) +
  scale_fill_manual(
    values = c("#00E227", "#a1f21d", "yellow", "#d0ff8f")
    ) +
  guides(fill = guide_none()) +
  labs(title = "34.9% of the global population remain unvaccinated against COVID-19",
       caption = "Data: Our World in Data") +
  theme_void()

ggsave("01_part_to_whole.png", width = 10, height = 6, units = "cm", dpi = 300)



data.frame(
  x = cos(1:10000) - sin(1:10000)^2 / sqrt(2),
  y = cos(1:10000) * sin(1:10000)
) %>% ggplot(., aes(x, y)) + geom_point() + theme_void()
