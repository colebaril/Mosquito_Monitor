library(rvest)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(readr)
library(httr)

# Winnipeg mosquito trap dataset API endpoint
api_url <- paste0(
  "https://data.winnipeg.ca/resource/du7c-8488.csv?$limit=50000"
)

# Download latest data
mosquito_data_latest <- read_csv(api_url,
                        show_col_types = FALSE)


# Old ----


master_data_old <- read_csv(url("https://github.com/colebaril/Mosquito_Monitor/blob/main/mosquito_data.csv?raw=TRUE"))

if(max(as.Date(master_data_old$date)) == max(as.Date(mosquito_data_latest$count_date))) {
  
  message(paste0("Data is already up to date as of ", Sys.Date(), "."))
  
  message(paste0("Data last updated: ", max(mosquito_data_latest$count_date), "."))
  
} else if(max(master_data_old$date) < max(mosquito_data_latest$count_date)) {
  
  message("New data detected. Running script...")

trap_data_metro <- mosquito_data_latest |> 
  select(1:3, starts_with("rural_")) |> 
  mutate(across(where(is.character), ~na_if(., "no data"))) |> 
  mutate(across(2:last_col(), ~as.numeric(.))) |> 
 
  pivot_longer(cols = matches("[a-z][a-z]") & -c("count_date", "city_wide_daily_average", "trap_days"),
               names_to = "trap",
               values_to = "number") |>  
  rename(date = count_date) |>  
  mutate(region = "Out of City Limits") |>  
  mutate(number = as.numeric(number)) |> 
  # distinct(trap, .keep_all = TRUE) |> 
  mutate(region_name = case_when(str_detect(trap, "aa") ~ "Lilyfield",
                            str_detect(trap, "bb") ~ "North Perimeter",
                            str_detect(trap, "cc") ~ "West St. Paul",
                            str_detect(trap, "dd") ~ "East St. Paul",
                            str_detect(trap, "ee") ~ "Springfield",
                            str_detect(trap, "ff") ~ "Ritchot",
                            str_detect(trap, "gg") ~ "MacDonald",
                            str_detect(trap, "hh") ~ "Headingly",
                            str_detect(trap, "ii") ~ "Rosser",
                            TRUE ~ NA)) |> 
  mutate(trap = str_remove(trap, "rural_"))

message("Metro data processed.")

trap_data_wpg <- mosquito_data_latest |>  
  select(-starts_with("rural_"), -north_west_average, -north_east_average, -south_east_average, -south_west_average) |> 
  mutate(across(where(is.character), ~na_if(., "no data"))) |> 
  mutate(across(2:last_col(), ~as.numeric(.))) |> 
  
  pivot_longer(cols = matches("[a-z][a-z]") & -c("count_date", "city_wide_daily_average", "trap_days"),
               names_to = "trap",
               values_to = "number") |>   
  rename(date = count_date) |> 
  mutate(
    region = trap |>
      str_remove("_\\d+$") |>
      str_replace("north_west", "NW") |>
      str_replace("north_east", "NE") |>
      str_replace("south_west", "SW") |>
      str_replace("south_east", "SE")
  ) |> 
  mutate(
    region_name = trap |>
      str_replace("north_west_", "NW") |>
      str_replace("north_east_", "NE") |>
      str_replace("south_west_", "SW") |>
      str_replace("south_east_", "SE")
  ) 

message("City data processed.")


master_data <- rbind(trap_data_wpg, trap_data_metro) 
  
message(paste0("Data has been updated on ", Sys.Date(), "."))
message(paste0("Website last updated ", max(mosquito_data_latest$count_date), "."))

write.csv(master_data, "mosquito_data.csv", row.names = FALSE)

message("Data saved to repository.")


}




