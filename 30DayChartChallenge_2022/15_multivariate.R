library(palmerpenguins)

penguins

cc <- penguins[complete.cases(penguins[, 1:6]),]

pca <- prcomp(cc[, 3:6], scale. = TRUE)

pca$rotation
pca$x


library(tidyverse)

pca$x %>% as.data.frame() %>%
  ggplot(aes(x = PC1, y = PC2)) +
  ggpubr::stat_chull(aes(color = cc$species,
                         fill = cc$species),
                     alpha = 0.1,
                     geom = "polygon") +
  geom_point(aes(col = cc$species)) +
  geom_segment(data = pca$rotation %>% as.data.frame(),
               aes(xend = PC1, yend = PC2, x = 0, y = 0),
               arrow = arrow(type = "closed",
                             length = unit(0.25,"cm"))) +
  ggrepel::geom_text_repel(data = pca$rotation %>% as.data.frame(),
                           aes(x = PC1, y = PC2, label = names(cc)[3:6])) +
  labs(title = "PCA of the palmer penguins data") +
  theme_classic() +
  theme(po)

ggsave("15_multivariate.png")

ggplot(cc, aes(x = flipper_length_mm, y = bill_depth_mm, col = species)) +
  geom_point()
