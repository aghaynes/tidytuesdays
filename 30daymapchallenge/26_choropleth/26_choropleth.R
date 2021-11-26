




library(tidyverse)
library(biscale)
library(cowplot)
library(sf)


vax <- readr::read_csv("https://github.com/owid/covid-19-data/raw/master/public/data/vaccinations/vaccinations.csv")
last_vax <- vax %>% 
  group_by(location) %>% 
  filter(date == max(date))

cases <- readr::read_csv("https://github.com/owid/covid-19-data/raw/master/public/data/jhu/COVID-19%20-%20Johns%20Hopkins%20University.csv")
last_cases <- cases %>% 
  group_by(Country) %>% 
  filter(Year == max(Year))

dat <- readr::read_csv("https://github.com/CSSEGISandData/COVID-19/raw/master/csse_covid_19_data/csse_covid_19_daily_reports/11-25-2021.csv")
last_cases <- dat %>%
  group_by(Country_Region) %>%
  summarise(incid = mean(Incident_Rate, na.rm = TRUE),
            fatal = mean(Case_Fatality_Ratio, na.rm = TRUE)) %>% 
  mutate(Country_Region = case_when(Country_Region == "US" ~ "United States",
                                    TRUE ~ Country_Region))

m <- left_join(last_cases, last_vax, by = c("Country_Region" = "location"))

countries <- rnaturalearth::ne_countries(returnclass = "sf")
m$iso_code

country_dat <- countries %>% left_join(m, by = c("iso_a3" = "iso_code")) %>%
  select(incid, total_vaccinations_per_hundred, iso_a3, Country_Region, sovereignt) %>% 
  bi_class(x = total_vaccinations_per_hundred, y = incid, dim = 3)

map <- ggplot() +
  geom_sf(data = country_dat %>% st_transform("+proj=wag7"), fill = "white", size = .5) +
  geom_sf(data = country_dat %>% st_transform("+proj=wag7") %>% 
            filter(!is.na(total_vaccinations_per_hundred) & !is.na(incid)), 
          aes(fill = bi_class), 
          show.legend = FALSE, 
          size = .1) +
  bi_scale_fill(pal = "DkBlue", dim = 3) +
  bi_theme() +
  labs(title = "COVID incidence and vaccinations", 
       caption = "Viz: @aghaynes; Data: Johns Hopkins University via OurWorldInData") +
  theme(plot.caption = element_text(size = 10))

legend <- bi_legend(pal = "DkBlue", 
                    xlab = "Vaccinations\nper 100",
                    y = "Biweekly\ncases") +
  theme(plot.background = element_rect(fill = NA))

m <- ggdraw() +
  draw_plot(map, 0, 0, 1, 1) +
  draw_plot(legend, 0.05, .05, 0.3, 0.3)

# ggplot(country_dat) + 
#   geom_point(aes(x = people_fully_vaccinated_per_hundred, 
#                  y = `Biweekly cases`)) +
#   ylim(0, 1500000)

ggsave("30daymapchallenge/26_choropleth/fig.png", m, height = 15, width = 25, units = "cm", dpi = 350)


