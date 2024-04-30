library(shiny)
library(rvest)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(DT)
library(shinythemes)
library(ggplot2)
library(readr)


# Define the URL you want to scrape
# url <- "https://legacy.winnipeg.ca/publicworks/insectcontrol/mosquitoes/trapcounts.stm"
# 
# # Function to scrape and save data
# scrape_and_save_data <- function() {
#   # Scrape data from the website
#   webpage <- read_html(url)
#   data <- webpage %>%
#     html_table(fill = TRUE) %>%
#     .[[2]]  # Assuming the data is in the first table
#   
#   # Load existing data (if any)
#   if (file.exists("data.csv")) {
#     existing_data <- read.csv("data.csv")
#   } else {
#     existing_data <- data.frame()
#   }
#   
#   # Append new data to the existing data frame
#   updated_data <- rbind(existing_data, data)
#   
#   # Save the updated data to a CSV file
#   write.csv(updated_data, "data.csv", row.names = FALSE)
#   
#   return(updated_data)
# }
# 
# '%!in%' <- function(x,y)!('%in%'(x,y))



# Define the Shiny UI
ui <- navbarPage(
  "Manitoba Mosquito Monitor",
  theme = shinytheme("flatly"),

  tabPanel(
    "Winnipeg",
    sidebarLayout(
      sidebarPanel(width = 3,
         h3("Winnipeg"),
         p("The City of Winnipeg Insect Control Branch monitors adult mosquito trap counts using New Jersey Light Traps which are permanent fixtures and attract mosquitoes via light. Traps are collected daily."),
         p("It should be noted that NJL traps do not use carbon dioxide as bait and yield significantly less specimens compared to carbon dioxide based traps such as those used by the City of Brandon."),
        
        selectInput(
          "wpg_data_type",
          "Select Dataset",
          choices = c("Winnipeg - Current",
                      "Winnipeg Metro - Current"),
          multiple = FALSE
        ),
        
        dateRangeInput(
          "date_range",
          "Date Range:",
          start = Sys.Date() - 14,
          end = Sys.Date() + 14
        )
      ),
      mainPanel(
        h3("Number of Mosquitoes by Region"),
        p("Average for region indicated by smooth line."),
       plotOutput("wpg_count_figure"),
        # Output summary data table
        h3("Data Summary"),
        dataTableOutput("data_table_summary")
       
       # h3("Historical Data")

      )
    )
  ),
  

  # BRANDON ----
  tabPanel(
    "Brandon",
    
    sidebarLayout(
      sidebarPanel(width = 3,
                   h3("Brandon"),
                   p("The City of Brandon monitors adult mosquito trap counts using CDC Light Traps which are temporary fixtures setup for the reason. Trapping is carried out twice weekly."),
                   p("CDC Light Traps use carbon dioxide as a bait which yields significantly more specimens compared to other methods (e.g., NJL traps)."),
                   
      ),
    
    
    mainPanel(
    h3("Historical Data"),
    
    dateRangeInput(
      "date_range_bdn_hist",
      "Date Range:",
      start = min(brandon_historical$sampling_dates),
      end = max(brandon_historical$sampling_dates)
      ),
    plotOutput("bdn_hist_fig")
    
    
    )
  )),
  

  
  tabPanel(
    "Data",
    sidebarLayout(
      sidebarPanel(),
      mainPanel(
        # Output data table
        dataTableOutput("data_table")
      )
    )
  ),
  
  tabPanel(
    "Manitoba - 2020-2021"
  )
)



# Define the Shiny server logic
server <- function(input, output, session) {
  
  # mosquito_data <<- readRDS("mosquito_data.rds") %>% 
  #   mutate(date = as_date(date)) 
  
  # Execute the scraping and saving function when the app starts
  # data <- scrape_and_save_data()
  
  # min_value <- 0
  # max_value <- 100
  
  master_data <- readRDS(url("https://github.com/colebaril/Mosquito_Monitor/blob/main/mosquito_data.rds?raw=TRUE"))
    # mutate(number = round(runif(n(), min = min_value, max = max_value)))
  
  # HISTORICAL DATA ----
  
  brandon_historical <- read_csv("mosquito_counts_historical-export_bdn.csv") %>% 
    clean_names() %>% 
    select(1:6) %>% 
    pivot_longer(!sampling_dates, names_to = "trap", values_to = "number") %>% 
    mutate(sampling_dates = as.Date(sampling_dates, format = "%Y-%m-%d"))

  
  # trap_data_metro <- data %>%
  #   row_to_names(24) %>% 
  #   select(matches("[a-z][a-z]")) %>% 
  #   select(-1) %>% slice(1) %>% 
  #   pivot_longer(cols = matches("[a-z][a-z]"),
  #                names_to = "trap",
  #                values_to = "number") %>% 
  #   mutate(number = na_if(number, "**")) %>% 
  #   mutate(number = na_if(number, "*")) %>% 
  #   mutate(date = Sys.Date()) %>% 
  #   mutate(region = "Out of City Limits") %>% 
  #   mutate(number = as.numeric(number)) %>% 
  #   distinct(trap, .keep_all = TRUE)
  # 
  # trap_data_wpg <- data %>% 
  #   select(1, 2) %>% 
  #   rename(trap = X1,
  #          number = X2) %>% 
  #   filter(str_detect(trap, "^[A-Za-z][A-Za-z]\\d$")) %>% 
  #   mutate(date = as.Date(Sys.Date(), format = "%Y-%m-%d")) %>%
  #   mutate(region = str_extract(trap, "^[A-Za-z][A-Za-z]")) %>% 
  #   mutate(number = na_if(number, "**")) %>% 
  #   mutate(number = na_if(number, "*")) %>% 
  #   mutate(number = as.numeric(number)) %>% 
  #   distinct(trap, .keep_all = TRUE)
  # 
  # master_data <- rbind(trap_data_wpg, trap_data_metro)
  
  master_data_summary <- master_data %>% 
    summarise(sum = sum(number),
              avg = mean(number),
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
  
  
  
  output$data_table_summary <- DT::renderDataTable({
    if(input$wpg_data_type == "Winnipeg - Current") {
    master_data_summary %>% 
        filter(region != "Out of City Limits") %>% 
      filter(date >= input$date_range[1]) %>% 
      filter(date <= input$date_range[2]) %>% 
      DT::datatable(.,
                  extensions = "Buttons",
                  options = list(
                    paging = TRUE, 
                    searching = TRUE,
                    dom = "Bfrtip",
                    buttons = c("csv", "excel")
                    # pageLength = 10
                  ),
                  class = "display") 
    } else if(input$wpg_data_type == "Winnipeg Metro - Current") {
      master_data_summary %>% 
        filter(region == "Out of City Limits") %>% 
        filter(date >= input$date_range[1]) %>% 
        filter(date <= input$date_range[2]) %>% 
        DT::datatable(.,
                      extensions = "Buttons",
                      options = list(
                        paging = TRUE, 
                        searching = TRUE,
                        dom = "Bfrtip",
                        buttons = c("csv", "excel")
                        # pageLength = 10
                      ),
                      class = "display") 
    }
  })
  

  
  output$wpg_count_figure <- renderPlot({
    
    if(input$wpg_data_type == "Winnipeg - Current") {
      
    master_data %>% 
      filter(region != "Out of City Limits") %>% 
      filter(date >= input$date_range[1]) %>% 
      filter(date <= input$date_range[2]) %>% 
      mutate(week = week(date)) %>% 
      # summarise(sum = sum(number),
      #           .by = c("region", "week")) %>% 
      ggplot(aes(x = factor(week), y = number)) +
      geom_jitter(width = 0.2) +
      geom_smooth(se = FALSE) +
        # geom_col(aes(fill = region)) +
      scale_fill_viridis_d("Region") +
      facet_wrap(~region) +
      theme_bw() +
      labs(x = "Week",
           y = "Total Mosquito Count")
    } else if(input$wpg_data_type == "Winnipeg Metro - Current") {
      master_data %>% 
        filter(region == "Out of City Limits") %>% 
        filter(date >= input$date_range[1]) %>% 
        filter(date <= input$date_range[2]) %>% 
        mutate(week = week(date)) %>% 
        # summarise(sum = sum(number),
        #           .by = c("region", "week")) %>% 
        ggplot(aes(x = factor(week), y = number)) +
        geom_jitter(width = 0.2) +
        geom_smooth(se = FALSE) +
        # geom_col(aes(fill = region)) +
        scale_fill_viridis_d("Region") +
        facet_wrap(~trap) +
        theme_bw() +
        labs(x = "Week",
             y = "Total Mosquito Count")
    }
    
    
  })
  
  # Brandon Historical Fig ----
  
  output$bdn_hist_fig <- renderPlot({
 
      brandon_historical %>% 
        filter(sampling_dates >= input$date_range_bdn_hist[1]) %>%
        filter(sampling_dates <= input$date_range_bdn_hist[2]) %>%
        mutate(week = week(sampling_dates)) %>% 
        mutate(year = year(sampling_dates)) %>% 
        # summarise(sum = sum(number),
        #           .by = c("region", "week")) %>% 
        ggplot(aes(x = factor(week), y = number)) +
        geom_jitter(width = 0.2, aes(colour = factor(year))) +
        geom_smooth(se = FALSE) +
        scale_colour_viridis_d("Year") +
        theme_bw() +
        labs(x = "Week",
             y = "Total Mosquito Count")
  })
  
}

shinyApp(ui, server)
