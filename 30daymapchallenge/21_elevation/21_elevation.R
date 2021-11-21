




zips <- list.files(here::here("30daymapchallenge/21_elevation/2mres"), ".zip", full.names = TRUE)
dat <- lapply(zips, function(x){
  files <- unzip(x, list = TRUE)
  out <- read_delim(unz(x, files$Name), delim = " ") 
  # out[seq(1, nrow(out), 100), ]
  out
}) %>% 
  bind_rows %>% 
  arrange(X, Y)



mat <- matrix(dat$Z, byrow = TRUE, ncol = length(unique(dat$X)))



library(rayshader)

surface_hillshade <- mat %>% 
  height_shade(
    texture = colorRampPalette(
      c("forestgreen", "palegreen4", "saddlebrown", "slategrey", "white"),
      bias = 1
    )(255)
  ) %>% 
  add_shadow(texture_shade(mat, detail = 0.9, brightness = 15), 0.7) %>% 
  add_shadow(ray_shade(mat, 
                       sunangle = 180,
                       sunaltitude = 80, 
                       zscale = zscale, 
                       multicore = TRUE), 0) 


plot_3d(surface_hillshade,
        mat,
        windowsize = c(800, 800),
        zscale = 10,
        # zoom = 0.5,
        solid = FALSE,
        theta = 0,
        phi = 90)

