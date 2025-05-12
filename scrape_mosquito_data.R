library(rvest)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(readr)

Sys.setenv(TZ = "America/Winnipeg")

# Define the URL you want to scrape
url <- "https://legacy.winnipeg.ca/publicworks/insectcontrol/mosquitoes/trapcounts.stm"

# Check date updated

webpage <- read_html(url)

date_updated <- html_nodes(webpage, "#lastUpdateDate") %>% 
  html_text() %>% 
  str_extract(., "\\b[A-Za-z]+ \\d{1,2}, \\d{4}\\b") 

date_updated <- format(as.Date(date_updated, "%B %d, %Y"), "%Y-%m-%d")

# Function to scrape and save data
scrape_and_save_data <- function() {
  # Scrape data from the website
  webpage <- read_html(url)
  
  data <- webpage %>%
    html_table(fill = TRUE) %>%
    .[[2]]  # Assuming the data is in the first table
  
  return(data)
}

master_data_old <- read_csv(url("https://github.com/colebaril/Mosquito_Monitor/blob/main/mosquito_data.csv?raw=TRUE"))

if(nrow(master_data_old) == 0) {
  
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
    mutate(date = Sys.Date()) %>% 
    mutate(region = "Out of City Limits") %>% 
    mutate(number = as.numeric(number)) %>% 
    distinct(trap, .keep_all = TRUE) %>% 
    mutate(region_name = case_when(str_detect(trap, "aa") ~ "Lilyfield",
                                   str_detect(trap, "bb") ~ "North Perimeter",
                                   str_detect(trap, "cc") ~ "West St. Paul",
                                   str_detect(trap, "dd") ~ "East St. Paul",
                                   str_detect(trap, "ee") ~ "Springfield",
                                   str_detect(trap, "ff") ~ "Ritchot",
                                   str_detect(trap, "gg") ~ "MacDonald",
                                   str_detect(trap, "hh") ~ "Headingly",
                                   str_detect(trap, "ii") ~ "Rosser",
                                   TRUE ~ NA)) 
  
  trap_data_wpg <- data %>% 
    select(1, 2) %>% 
    rename(trap = X1,
           number = X2) %>% 
    filter(str_detect(trap, "^[A-Za-z][A-Za-z]\\d$")) %>% 
    mutate(date = as.Date(Sys.Date(), format = "%Y-%m-%d")) %>%
    mutate(region = str_extract(trap, "^[A-Za-z][A-Za-z]")) %>% 
    mutate(number = na_if(number, "**")) %>% 
    mutate(number = na_if(number, "*")) %>% 
    mutate(number = as.numeric(number)) %>% 
    distinct(trap, .keep_all = TRUE) %>% 
    mutate(region_name = trap)
  
  
  master_data <- rbind(trap_data_wpg, trap_data_metro, master_data_old) 
  
  message(paste0("Data has been updated on ", Sys.Date(), "."))
  message(paste0("Website last updated ", date_updated, "."))
  
  write.csv(master_data, "mosquito_data.csv", row.names = FALSE)
  
} else if(max(master_data_old$date) == Sys.Date()) {
  
  message(paste0("Data is already up to date as of ", Sys.Date(), "."))
  
  message(paste0("Website last updated: ", date_updated, "."))
  
} else if(max(master_data_old$date) != Sys.Date()) {
  
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
    mutate(date = Sys.Date()) %>% 
    mutate(region = "Out of City Limits") %>% 
    mutate(number = as.numeric(number)) %>% 
    distinct(trap, .keep_all = TRUE) %>% 
    mutate(region_name = case_when(str_detect(trap, "aa") ~ "Lilyfield",
                                   str_detect(trap, "bb") ~ "North Perimeter",
                                   str_detect(trap, "cc") ~ "West St. Paul",
                                   str_detect(trap, "dd") ~ "East St. Paul",
                                   str_detect(trap, "ee") ~ "Springfield",
                                   str_detect(trap, "ff") ~ "Ritchot",
                                   str_detect(trap, "gg") ~ "MacDonald",
                                   str_detect(trap, "hh") ~ "Headingly",
                                   str_detect(trap, "ii") ~ "Rosser",
                                   TRUE ~ NA)) 
  
  trap_data_wpg <- data %>% 
    select(1, 2) %>% 
    rename(trap = X1,
           number = X2) %>% 
    filter(str_detect(trap, "^[A-Za-z][A-Za-z]\\d$")) %>% 
    mutate(date = as.Date(Sys.Date(), format = "%Y-%m-%d")) %>%
    mutate(region = str_extract(trap, "^[A-Za-z][A-Za-z]")) %>% 
    mutate(number = na_if(number, "**")) %>% 
    mutate(number = na_if(number, "*")) %>% 
    mutate(number = as.numeric(number)) %>% 
    distinct(trap, .keep_all = TRUE) %>% 
    mutate(region_name = trap)
  
  
  master_data <- rbind(trap_data_wpg, trap_data_metro, master_data_old) 
  
  message(paste0("Data has been updated on ", Sys.Date(), "."))
  message(paste0("Website last updated ", date_updated, "."))
  
  write.csv(master_data, "mosquito_data.csv", row.names = FALSE)
  
  
}



