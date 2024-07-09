library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(ggplot2)
library(readr)

# Sys.sleep(360)

master_data <- read_csv(url("https://raw.githubusercontent.com/colebaril/Mosquito_Monitor/main/mosquito_data_bdn.csv")) |> 
  mutate(`Sampling Dates` = as.Date(`Sampling Dates`))

master_data <- master_data |> 
  filter(`Sampling Dates` == max(master_data$`Sampling Dates`)) |> 
  mutate(Week = week(`Sampling Dates`))

plot <- master_data |> 
  pivot_longer(!`Sampling Dates` & !`Daily Average Count` & !`Week`, names_to = "Trap", values_to = "Number") |> 
  ggplot() +
  geom_col(aes(x = Trap, y = Number)) +
  geom_hline(colour = "firebrick3", linewidth = 2, yintercept = as.numeric(head(master_data$`Daily Average Count`))) +
  theme_bw(base_size = 20) +
  labs(x = "Trap",
       y = "Number of Specimens",
       title = paste0("Brandon Mosquito Trap Count Summary"),
       subtitle = paste0("Last Updated ", format(head(master_data$`Sampling Dates`), "%A, %B %d, %Y"), "\nCity Wide Average: ", 
                         head(master_data$`Daily Average Count`)),
       caption = "Average indicated by the red horizontal line. Viz by Cole Baril | colebaril.ca") +
  theme(plot.title = element_text(face = "bold"))

ggsave("bdn_mosquito_update_table.png", plot = plot, dpi = 300, units = "in", width = 9, height = 9, limitsize = FALSE)
