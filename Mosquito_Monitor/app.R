library(shiny)
library(rvest)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(DT)
library(shinythemes)


# Define the URL you want to scrape
url <- "https://legacy.winnipeg.ca/publicworks/insectcontrol/mosquitoes/trapcounts.stm"

# Function to scrape and save data
scrape_and_save_data <- function() {
  # Scrape data from the website
  webpage <- read_html(url)
  data <- webpage %>%
    html_table(fill = TRUE) %>%
    .[[2]]  # Assuming the data is in the first table
  
  # Load existing data (if any)
  if (file.exists("data.csv")) {
    existing_data <- read.csv("data.csv")
  } else {
    existing_data <- data.frame()
  }
  
  # Append new data to the existing data frame
  updated_data <- rbind(existing_data, data)
  
  # Save the updated data to a CSV file
  write.csv(updated_data, "data.csv", row.names = FALSE)
  
  return(updated_data)
}

'%!in%' <- function(x,y)!('%in%'(x,y))

# Define the Shiny UI
ui <- navbarPage(
  "Winnipeg Mosquito Trap Counts",
  theme = shinytheme("flatly"),

  tabPanel(
    "Summary",
    sidebarLayout(
      sidebarPanel(
        dateRangeInput(
          "date_range",
          "Date Range:",
          start = Sys.Date() - 7,
          end = Sys.Date()
        )
      ),
      mainPanel(
        # Output summary data table
        h3("Sum of Traps in Region"),
        dataTableOutput("data_table_summary_sum"),
        h3("Average of Traps in Region"),
        dataTableOutput("data_table_summary_avg")
      )
    )
  ),
  tabPanel(
    "Data",
    sidebarLayout(
      sidebarPanel(),
      mainPanel(
        # Output data table
        dataTableOutput("data_table")
      )
    )
  )
)



# Define the Shiny server logic
server <- function(input, output, session) {
  
  # mosquito_data <<- readRDS("mosquito_data.rds") %>% 
  #   mutate(date = as_date(date)) 
  
  # Execute the scraping and saving function when the app starts
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
    distinct(trap, .keep_all = TRUE)

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
    distinct(trap, .keep_all = TRUE)
  
  master_data <- rbind(trap_data_wpg, trap_data_metro)
  
  master_data_summary_sum <- master_data %>% 
    summarise(sum = sum(number),
              .by = c("region", "date"))
  
  master_data_summary_avg <- master_data %>% 
    summarise(avg = mean(number),
              .by = c("region", "date"))
  
  output$message <- renderText({
    "Data has been scraped and saved."
  })
  
  output$data_table <- DT::renderDataTable({
    DT::datatable(master_data,
                  extensions = "Buttons",
                  options = list(
                    paging = TRUE, 
                    searching = TRUE,
                    dom = "Bfrtip",
                    buttons = c("csv", "excel")
                    # pageLength = 10
                  ),
                  class = "display") 
  })
  
  output$data_table_summary_sum <- DT::renderDataTable({
    DT::datatable(master_data_summary,
                  extensions = "Buttons",
                  options = list(
                    paging = TRUE, 
                    searching = TRUE,
                    dom = "Bfrtip",
                    buttons = c("csv", "excel")
                    # pageLength = 10
                  ),
                  class = "display") 
  })
  
  output$data_table_summary_avg <- DT::renderDataTable({
    DT::datatable(master_data_summary,
                  extensions = "Buttons",
                  options = list(
                    paging = TRUE, 
                    searching = TRUE,
                    dom = "Bfrtip",
                    buttons = c("csv", "excel")
                    # pageLength = 10
                  ),
                  class = "display") 
  })
}

shinyApp(ui, server)
