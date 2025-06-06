library(sf)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(ggplot2)
library(readr)

# Wait 3 minutes before running. Weird bug occurred where the previous data is used if the figure update script starts too fast. 

Sys.setenv(TZ = "America/Winnipeg")

Sys.sleep(180)

master_data <- read_csv(url("https://github.com/colebaril/Mosquito_Monitor/blob/main/mosquito_data.csv?raw=TRUE"))

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
              destfile = "Master.zip")

print("Downloaded Data")

unzip(zipfile = "Master.zip")

print("Unzipped data")

print(list.files("Mosquito_Monitor-be9f58d9fb6bc1940a67215cff8dd33e719bd780"))

shape <- read_sf("Mosquito_Monitor-be9f58d9fb6bc1940a67215cff8dd33e719bd780/Shape Data/wpg_shape_data.shp")

wpg_shape_data <- shape

# Define the bins for mosquito counts
bins <- c(0, 1, 10, 50, 100, 500, 1000, 3000)
labels <- c("0", "1-10", "11-50", "51-100", "101-500", "501-1,000", "1,001-3,000")
values = c("#440154FF", "#443A83FF", "#31688EFF", "#21908CFF", "#35B779FF", "#8FD744FF", "#FDE725FF")


city_mean <- master_data %>% 
  filter(date == max(master_data$date)) |> 
  summarise(mean = mean(as.numeric(number), na.rm=TRUE)) |> 
  pull() |> round(digits = 2)


plot <- master_data %>% 
  filter(date == max(master_data$date)) %>%
  full_join(wpg_shape_data, by = c("trap" = "trap_name")) %>% 
  filter(map_type == "Winnipeg") %>% 
  mutate(binned_number = cut(number, breaks = bins, labels = labels, include.lowest = TRUE, right = FALSE)) %>%
  mutate(binned_number = factor(binned_number, levels = c("0", "1-10", "11-50", "51-100", "101-500", "501-1,000", "1,001-3,000"))) %>%
  ggplot(aes(geometry = geometry, fill = binned_number), show.legend = TRUE, colour = "black") +
  geom_sf(show.legend = TRUE) +
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
  scale_fill_manual("Number of \nMosquitoes", values = values, na.value = "grey50", drop = FALSE) +
  labs(title = "Winnipeg Mosquito Trap Count Summary",
       subtitle = paste0("Last Updated ", format(Sys.Date(), "%A, %B %d, %Y"), "\nCity Wide Average: ", city_mean),
       caption = "Grey/white zones: no data. Counts for areas out of city limits displayed as text.") +
  theme(legend.position = "left",
        plot.caption = element_text(hjust = 0),
        plot.title = element_text(face = "bold"))

ggsave("wpg_mosquito_map_tmp.png", plot = plot, dpi = 300, units = "in", width = 11, height = 11, limitsize = FALSE)
