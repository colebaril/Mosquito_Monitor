library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(ggplot2)
library(readr)
library(gt)
library(webshot2)

Sys.sleep(60)

master_data <- read_csv(url("https://raw.githubusercontent.com/colebaril/Mosquito_Monitor/main/mosquito_data_bdn.csv")) |> 
  mutate(`Sampling Dates` = as.Date(`Sampling Dates`))

master_data |> 
  filter(`Sampling Dates` == max(master_data$`Sampling Dates`)) |> 
  mutate(Week = week(`Sampling Dates`)) |> 
  relocate(Week, .after = `Sampling Dates`) |> 
  rename("Date" = `Sampling Dates`,
         "Average" = `Daily Average Count`) |> 
  gt() |> 
  data_color(columns = `Trap 1`:`Trap 5`,
             direction = "row",
             palette = "viridis") |> 
  tab_header("City of Brandon Mosquito Trap Counts") |> 
  tab_footnote("Viz & Workflow by Cole Baril | colebaril.ca") |> 
  gtsave("bdn_mosquito_update_table.png")
