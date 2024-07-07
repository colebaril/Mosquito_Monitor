library(rvest)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(readr)
library(httr)
library(jsonlite)

# Define the base API endpoint for the "mosquito_counts" dataset
base_url <- "https://opendata.brandon.ca/opendataservice/default.aspx?format=json&dataset=mosquito_counts"

# Define the columns to retrieve
columns <- c("Trap 1", "Trap 2", "Trap 3", "Trap 4", "Trap 5")

# Function to retrieve data for a single column
get_data_for_column <- function(column) {
  data_url <- paste0(base_url, "&columns=", URLencode(column), "&limit=1000")
  response <- GET(data_url)
  
  # Check if the request was successful
  if (response$status_code == 200) {
    # Parse the JSON content
    data <- content(response, "parsed", simplifyVector = TRUE)
    return(data)
  } else {
    print(paste("Failed to retrieve data for column:", column, "Status code:", response$status_code))
    return(NULL)
  }
}

# Retrieve data for each column and combine into a single data frame
all_data <- lapply(columns, get_data_for_column)

# Combine the data into a single data frame
mosquito_df <- do.call(cbind, lapply(all_data, function(x) as.data.frame(x)))

# Print the first few rows of the combined data frame

mosquito_df <- mosquito_df |> 
  select(1:7) |> 
  mutate(`Sampling Dates` = as.Date(`Sampling Dates`))

date_updated <- as.Date(max(mosquito_df$`Sampling Dates`, na.rm=TRUE))


master_data_old <- read_csv(url("https://raw.githubusercontent.com/colebaril/Mosquito_Monitor/main/mosquito_data_bdn.csv")) |> 
  mutate(`Sampling Dates` = as.Date(`Sampling Dates`))

if(nrow(master_data_old) == nrow(mosquito_df)) {
  message(paste0("Data is already up to date as of ", Sys.Date(), "."))
  
  message(paste0("Website last updated: ", date_updated, "."))
} else {
  
  master_data <- mosquito_df
  
  message(paste0("Data has been updated on ", Sys.Date(), "."))
  message(paste0("Website last updated ", date_updated, "."))
  
  write.csv(master_data, "mosquito_data_bdn.csv", row.names = FALSE)
  
  
}




