library(sf)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(ggplot2)
library(readr)

master_data <- readRDS(url("https://github.com/colebaril/Mosquito_Monitor/blob/main/mosquito_data.rds?raw=TRUE"))

n_ross <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  filter(trap == "ii") %>% 
  select(number) %>% 
  pull()

n_head <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  filter(trap == "hh") %>% 
  select(number) %>% 
  pull()

n_mac <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  filter(trap == "gg") %>% 
  select(number) %>% 
  pull()

n_ritch <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  filter(trap == "ee") %>% 
  select(number) %>% 
  pull()

n_esp <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  filter(trap == "dd") %>% 
  select(number) %>% 
  pull()

n_wsp <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  filter(trap == "cc") %>% 
  select(number) %>% 
  pull()

n_nper <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  filter(trap == "bb") %>% 
  select(number) %>% 
  pull()

n_springfield <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  filter(trap == "ff") %>% 
  select(number) %>% 
  pull()

n_lilyfield <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  filter(trap == "aa") %>% 
  select(number) %>% 
  pull()

download.file(url = "https://github.com/colebaril/Mosquito_Monitor/archive/be9f58d9fb6bc1940a67215cff8dd33e719bd780.zip",
              destfile = "Clone/Master.zip")

print("Downloaded Data")

unzip(zipfile = "Clone/Master.zip")

print("Unzipped data")

print(list.files("Mosquito_Monitor-be9f58d9fb6bc1940a67215cff8dd33e719bd780"))

shape <- read_sf("Mosquito_Monitor-be9f58d9fb6bc1940a67215cff8dd33e719bd780/Shape Data/wpg_shape_data.shp")

wpg_shape_data <- shape

plot <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  full_join(wpg_shape_data, by = c("trap" = "trap_name")) %>% 
  filter(map_type == "Winnipeg") %>% 
  ggplot(aes(geometry = geometry, fill = number)) +
  geom_sf() +
  annotate("text", x = 5815500, y = 1550000, label = paste0("Lilyfield\n", n_lilyfield),
           size = 5, color = "black") +
  annotate("text", x = 5829000, y = 1527500, label = paste0("Springfield\n", n_springfield),
           size = 5, color = "black") +
  annotate("text", x = 5812500, y = 1530000, label = paste0("Macdonald\n", n_mac),
           size = 5, color = "black") +
  annotate("text", x = 5807500, y = 1540000, label = paste0("Headingley\n", n_head),
           size = 5, color = "black") +
  annotate("text", x = 5806500, y = 1545000, label = paste0("Rosser\n", n_ross),
           size = 5, color = "black") +
  annotate("text", x = 5832500, y = 1550000, label = paste0("East Saint Paul\n", n_esp),
           size = 5, color = "black") +
  annotate("text", x = 5828000, y = 1554000, label = paste0("West Saint Paul\n", n_wsp),
           size = 5, color = "black") +
  annotate("text", x = 5820000, y = 1555000, label = paste0("North Perimeter\n", n_nper),
           size = 5, color = "black") +
  annotate("text", x = 5832500, y = 1537500, label = paste0("Ritchot\n", n_ritch),
           size = 5, color = "black") +
  theme_void(base_size = 20) +
  scale_fill_viridis_c("Total \nMosquitoes") +
  theme(legend.position = "left")

ggsave("wpg_mosquito_map_tmp.png", plot = plot, dpi = 300, units = "in", width = 10, height = 10, limitsize = FALSE)
