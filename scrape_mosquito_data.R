library(rvest)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(readr)

# Test
# Define the URL you want to scrape
url <- "https://legacy.winnipeg.ca/publicworks/insectcontrol/mosquitoes/trapcounts.stm"

# Function to scrape and save data
scrape_and_save_data <- function() {
  # Scrape data from the website
  webpage <- read_html(url)
  data <- webpage %>%
    html_table(fill = TRUE) %>%
    .[[2]]  # Assuming the data is in the first table

  return(data)
}

master_data_old <- readRDS(url("https://github.com/colebaril/Mosquito_Monitor/blob/main/mosquito_data.rds?raw=TRUE")) 
  # mutate(date = date-10) %>% 
  # mutate(region_name = trap)

if(max(master_data_old$date) == Sys.Date()) {
  message(paste0("Data is already up to date as of ", Sys.Date(), "."))
} else {

data <- scrape_and_save_data()

trap_data_metro <- data %>%
  row_to_names(24) %>% 
  select(matches("[a-z][a-z]")) %>% 
  select(-1) %>% slice(1) %>% 
  pivot_longer(cols = matches("[a-z][a-z]"),
               names_to = "trap",
               values_to = "number") %>% 
  mutate(number = na_if(number, "**")) %>% 
  mutate(number = na_if(number, "*")) %>% 
  mutate(date = Sys.Date()-5) %>% 
  mutate(region = "Out of City Limits") %>% 
  mutate(number = as.numeric(number)) %>% 
  distinct(trap, .keep_all = TRUE) %>% 
  mutate(region_name = case_when(trap == "aa" ~ "aa",
                            trap == "bb" ~ "bb",
                            trap == "cc" ~ "West St. Paul",
                            trap == "dd" ~ "East St. Paul",
                            trap == "ee" ~ "Oakbank",
                            trap == "ff" ~ "Springfield",
                            trap == "gg" ~ "Oak Bluff",
                            trap == "hh" ~ "MacDonald",
                            trap == "ii" ~ "Headingly",
                            TRUE ~ NA))

trap_data_wpg <- data %>% 
  select(1, 2) %>% 
  rename(trap = X1,
         number = X2) %>% 
  filter(str_detect(trap, "^[A-Za-z][A-Za-z]\\d$")) %>% 
  mutate(date = as.Date(Sys.Date(), format = "%Y-%m-%d")-5) %>%
  mutate(region = str_extract(trap, "^[A-Za-z][A-Za-z]")) %>% 
  mutate(number = na_if(number, "**")) %>% 
  mutate(number = na_if(number, "*")) %>% 
  mutate(number = as.numeric(number)) %>% 
  distinct(trap, .keep_all = TRUE) %>% 
  mutate(region_name = trap)


master_data <- rbind(trap_data_wpg, trap_data_metro, master_data_old) 
  

master_data %>% 
  write_rds("mosquito_data.rds")
}
