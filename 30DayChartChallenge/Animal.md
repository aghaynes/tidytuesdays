PalmerPenguins
================

``` r
library(palmerpenguins)
```

    ## Warning: package 'palmerpenguins' was built under R version 4.0.5

``` r
library(ggplot2)
```

    ## Warning: package 'ggplot2' was built under R version 4.0.5

``` r
library(ggExtra)
```

    ## Warning: package 'ggExtra' was built under R version 4.0.5

``` r
library(magrittr)
```

    ## Warning: package 'magrittr' was built under R version 4.0.4

``` r
penguins %>%
  ggplot(aes(x = bill_depth_mm, y = flipper_length_mm, col = species)) +
  geom_point() +
  theme_dark() +
  theme(legend.position = "bottom") +
  xlab("Bill depth (mm)") +
  ylab("Flipper length (mm)") -> p
ggMarginal(p, type = "histogram")
```

    ## Warning: Removed 2 rows containing missing values (geom_point).

![](Animal_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->
