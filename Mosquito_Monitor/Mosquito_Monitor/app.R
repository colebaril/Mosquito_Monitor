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

# LOAD DATA ----

brandon_historical <- read_csv("mosquito_counts_historical-export_bdn.csv") %>% 
  clean_names() %>% 
  select(1:6) %>% 
  pivot_longer(!sampling_dates, names_to = "trap", values_to = "number") %>% 
  mutate(sampling_dates = as.Date(sampling_dates, format = "%Y-%m-%d")) %>% 
  mutate(year = year(sampling_dates))

wmb <- read_csv(url("https://github.com/colebaril/mosquitoes_weather/blob/main/Data/Datasets/mosquitoes.csv?raw=TRUE")) %>% 
  select(1:7) %>% 
  mutate(year = year(date)) %>% 
  filter(site != "Winnipeg",
         site != "West Saint Paul 6")
  

winnipeg_historical <- read_csv("Daily_Adult_Mosquito_Trap_Data_20240506.csv") %>% 
  clean_names() %>% 
  mutate(across(everything(), as.character)) %>%  
  mutate(across(everything(), ~na_if(., "no data"))) %>%  
  select(!contains("average"), -trap_days) %>% 
  mutate(count_date = as.Date(count_date, format = "%d/%m/%Y")) %>%
  mutate(count_date = format(count_date, "%Y-%m-%d")) %>% 
  pivot_longer(!count_date, names_to = "trap", values_to = "number") %>% 
  mutate(year = year(count_date)) %>% 
  mutate(week = week(count_date)) %>% 
  mutate(number = as.numeric(number)) %>% 
  mutate(region = case_when(str_detect(trap, "north_west") ~ "WPG - North West",
                            str_detect(trap, "south_west") ~ "WPG - South West",
                            str_detect(trap, "south_east") ~ "WPG - South East",
                            str_detect(trap, "north_east") ~ "WPG - North East",
                            str_detect(trap, "aa") ~ "Lilyfield",
                            str_detect(trap, "bb") ~ "North Perimeter",
                            str_detect(trap, "cc") ~ "West St. Paul",
                            str_detect(trap, "dd") ~ "East St. Paul",
                            str_detect(trap, "ee") ~ "Springfield",
                            str_detect(trap, "ff") ~ "Ritchot",
                            str_detect(trap, "gg") ~ "MacDonald",
                            str_detect(trap, "hh") ~ "Headingly",
                            str_detect(trap, "ii") ~ "Rosser",
                            TRUE ~ NA)) %>% 
  mutate(region = as.factor(region)) %>% 
  rename(region_name = region) %>% 
  mutate(region = case_when(str_detect(region_name, "North West") ~ "NW",
                            str_detect(region_name, "North East") ~ "NE",
                            str_detect(region_name, "South West") ~ "SW",
                            str_detect(region_name, "South East") ~ "SE",
                            TRUE ~ "Outside of City Limits")) %>% 
  mutate(count_date = as.Date(count_date))


# UI ----
# Define the Shiny UI
ui <- navbarPage(
  title = div(
    tags$img(src = "main-logo.png", height = 20, width = 20),
    tags$a(href = "https://github.com/colebaril/Mosquito_Monitor", "Manitoba Mosquito Monitor", target = "_blank")
    
  ),
  theme = shinytheme("simplex"),
## WINNIPEG ----
  tabPanel(
    "Winnipeg",
    sidebarLayout(
      sidebarPanel(width = 2,
         h3("Winnipeg"),
         p("The City of Winnipeg Insect Control Branch monitors adult mosquito trap counts using New Jersey Light Traps which are permanent fixtures and attract mosquitoes via light. Traps are collected daily."),
         p("It should be noted that NJL traps do not use carbon dioxide as bait and yield significantly less specimens compared to carbon dioxide based traps such as those used by the City of Brandon."),
        
        selectInput(
          "wpg_data_type",
          "Select Dataset",
          choices = c("Winnipeg",
                      "Outside City Limits"),
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
        
        checkboxGroupInput(
          "date_range_wpg_current",
          "Choose Historical Data Years:",
          choices = min(winnipeg_historical$year):max(winnipeg_historical$year),
          selected = min(winnipeg_historical$year):max(winnipeg_historical$year),
          inline = TRUE
        ),

       uiOutput("plotorprint_wpg"),
       
        # Output summary data table
        h3("Data Summary"),
        dataTableOutput("data_table_summary"),
       
       h3("Historical Data"),
       
       checkboxGroupInput(
         "date_range_wpg_hist",
         "Choose Year(s):",
         choices = min(winnipeg_historical$year):max(winnipeg_historical$year),
         selected = min(winnipeg_historical$year):max(winnipeg_historical$year),
         inline = TRUE
       ),
       
       checkboxGroupInput(
         "region_wpg_hist",
         "Choose Trapping Region:",
         choices = unique(winnipeg_historical$region),
         selected = unique(winnipeg_historical$region),
         inline = TRUE
       ),
       
       plotOutput("wpg_hist_fig")

      )
    )
  ),
  

  ## BRANDON ----
  tabPanel(
    "Brandon",
    
    sidebarLayout(
      sidebarPanel(width = 3,
                   h3("Brandon"),
                   p("The City of Brandon monitors adult mosquito trap counts using CDC Light Traps which are temporary fixtures setup for the reason. Trapping is carried out twice weekly."),
                   p("CDC Light Traps use carbon dioxide as a bait which yields significantly more specimens compared to other methods (e.g., NJL traps).")
                   
      ),
    
    
    mainPanel(
    h3("Historical Data"),
    
    checkboxGroupInput(
      "date_range_bdn_hist",
      "Choose Year(s):",
      choices = min(brandon_historical$year):max(brandon_historical$year),
      selected = min(brandon_historical$year):max(brandon_historical$year),
      inline = TRUE
    ),
    plotOutput("bdn_hist_fig")
    
    
    )
  )),
  
## RURAL MB ----
  tabPanel(
    "Rural Manitoba",
    sidebarLayout(
      sidebarPanel(width = 3,
                   h3("Rural Manitoba"),
                   p("From 2020-2021, Cole Baril (former Graduate Researcher, Brandon University) led an extensive mosquito surveillance project funded by the Public Health Agency of Canada's Infectious Diseases and Climate Change Fund."),
                   p("The project involved twice-weekly surveillance of mosquitoes using CDC Light Traps in rural towns in Manitoba. All mosquitoes were identified to species."),
                   p("Weekly reports were sent to local municipalities, Manitoba Health and the Public Health Agency of Canada outlining mosquito trap counts, the number of California serogroup virus detections, and public health guidance on how to protect yourself from mosquito bites."),
                   p("The mosquito surveillance aspect of this project was published in Parasites and Vectors in 2023."),
                   tags$a(href="https://parasitesandvectors.biomedcentral.com/articles/10.1186/s13071-023-05760-x", "Click here to read my research article.")),
      
      mainPanel(
        h3("Overall Trap Counts"),
        
        checkboxGroupInput(
          "date_range_wmb_hist",
          "Choose Year(s):",
          choices = min(wmb$year):max(wmb$year),
          selected = min(wmb$year):max(wmb$year),
          inline = TRUE
        ),
        
        checkboxGroupInput(
          "region_wmb_hist",
          "Choose Region(s):",
          choices = unique(wmb$site),
          selected = unique(wmb$site),
          inline = TRUE
        ),
        
        plotOutput("wmb_hist_fig"),
        
        h3("Trap Counts by Species & Location"),
        
        selectInput(
          "date_range_wmb_species",
          "Choose Year(s):",
          choices = min(wmb$year):max(wmb$year),
          multiple = FALSE
        ),
        
        plotOutput("wmb_hist_fig_species", height = "800px")
        
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
  ),
  

)



# SERVER ----
server <- function(input, output, session) {
  
  # min_value <- 0
  # max_value <- 100
  
  master_data <- readRDS(url("https://github.com/colebaril/Mosquito_Monitor/blob/main/mosquito_data.rds?raw=TRUE"))
    # mutate(number = round(runif(n(), min = min_value, max = max_value)))
  

  
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
  
  
  # WPG DATATABLE ----
  
  output$data_table_summary <- DT::renderDataTable({
    if(input$wpg_data_type == "Winnipeg") {
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
    } else if(input$wpg_data_type == "Outside City Limits") {
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
  
# WPG FIGURES ----
  
  output$wpg_count_figure <- renderPlot({
    
    if(input$wpg_data_type == "Winnipeg") {
      
    master_data %>% 
      filter(region != "Out of City Limits") %>% 
      filter(date >= input$date_range[1]) %>%
      filter(date <= input$date_range[2]) %>%
      mutate(week = week(date)) %>% 
      ggplot(aes(x = factor(week), y = number)) +
      geom_jitter(data = winnipeg_historical %>%
                    filter(!str_detect(trap, "rural")) %>% 
                    filter(as.factor(year) %in% input$date_range_wpg_current) %>% 
                    filter(as.Date(format(count_date, "%m-%d"), format = "%m-%d") >= 
                             as.Date(format(input$date_range[1], "%m-%d"), format = "%m-%d")) %>%
                    filter(as.Date(format(count_date, "%m-%d"), format = "%m-%d") <= 
                             as.Date(format(input$date_range[2], "%m-%d"), format = "%m-%d")),
                  width = 0.2, colour = "grey70", alpha = 0.5) +
        geom_jitter(width = 0.2, shape = 21, fill = 'firebrick4', alpha = 0.5, size = 2) +
      scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
      facet_wrap(~region) +
      theme_bw(base_size = 15) +
      labs(x = "Week",
           y = "Total Mosquito Count",
           subtitle = "Current year shown in red. Historical data shown in grey.")
      
    } else if(input$wpg_data_type == "Outside City Limits") {
      master_data %>% 
        filter(region == "Out of City Limits") %>% 
        filter(date >= input$date_range[1]) %>%
        filter(date <= input$date_range[2]) %>%
        mutate(week = week(date)) %>% 
        ggplot(aes(x = factor(week), y = number)) +
        geom_jitter(data = winnipeg_historical %>%
                      filter(str_detect(trap, "rural")) %>% 
                      filter(as.factor(year) %in% input$date_range_wpg_current) %>% 
                      filter(as.Date(format(count_date, "%m-%d"), format = "%m-%d") >= 
                               as.Date(format(input$date_range[1], "%m-%d"), format = "%m-%d")) %>%
                      filter(as.Date(format(count_date, "%m-%d"), format = "%m-%d") <= 
                               as.Date(format(input$date_range[2], "%m-%d"), format = "%m-%d")),
                    width = 0.2, colour = "grey70", alpha = 0.5) +
        geom_jitter(width = 0.2, shape = 21, fill = 'firebrick4', alpha = 0.5, size = 2) +
        scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
        facet_wrap(~region_name) +
        theme_bw(base_size = 15) +
        labs(x = "Week",
             y = "Total Mosquito Count",
             subtitle = "Current year shown in red. Historical data shown in grey.")
    }
    
    
  })
  
  output$plotorprint_wpg <- renderUI({
    if(all(is.na(master_data$number))) {
      renderText({
        "No data. It's likely there's no data available from the City of Winnipeg yet."
      })
    } else {
      plotOutput("wpg_count_figure", height = 500)
    }
  })
  
  # BDN HISTORICAL FIG ----
  
  output$bdn_hist_fig <- renderPlot({
 
      brandon_historical %>% 
        filter(year %in% input$date_range_bdn_hist) %>%
        mutate(week = week(sampling_dates)) %>% 
        ggplot(aes(x = factor(week), y = number)) +
        geom_jitter(width = 0.3, aes(colour = factor(year)), size = 3) +
        scale_colour_viridis_d("Year") +
        scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
        theme_bw() +
        labs(x = "Week",
             y = "Total Mosquito Count") +
      theme(text=element_text(size=20))
  })
  
  # WPG HISTORICAL FIG ----
  
  output$wpg_hist_fig <- renderPlot({
    
    winnipeg_historical %>% 
      filter(year %in% input$date_range_wpg_hist) %>%
      filter(region %in% input$region_wpg_hist) %>% 
      mutate(week = week(count_date)) %>% 
      ggplot(aes(x = factor(week), y = number)) +
      geom_jitter(width = 0.3, aes(colour = factor(year)), size = 3) +
      scale_colour_viridis_d("Year") +
      scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
      theme_bw() +
      labs(x = "Week",
           y = "Total Mosquito Count") +
      theme(text=element_text(size=20))
  })
  
  # WMB HISTORICAL FIG ----
  
  ## TOTALS ----
  
  output$wmb_hist_fig <- renderPlot({
    
    wmb %>% 
      rename(Species = species) %>% 
      filter(year %in% input$date_range_wmb_hist) %>%
      filter(site %in% input$region_wmb_hist) %>%
      mutate(week = week(date)) %>% 
      ggplot(aes(x = factor(week), y = trapcount)) +
      geom_jitter(width = 0.3, aes(colour = factor(year), shape = Species), size = 3) +
      scale_colour_manual("Year", values = c("forestgreen", "cadetblue")) +
      scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
      theme_bw() +
      labs(x = "Week",
           y = "Total Mosquito Count") +
      theme(text=element_text(size=20)) +
      guides(shape = guide_legend(label.theme = element_text(face = "italic")))
    
  })
  
  output$wmb_hist_fig_species <- renderPlot({
    # Only show every second week
    everysecond <- function(x){
      if (length(x) > 0) {
        x <- sort(unique(x))
        x[seq(2, length(x), 2)] <- ""
      }
      x
    }
    
    
    wmb %>% 
      filter(year == input$date_range_wmb_species) %>%
      mutate(week = week(date)) %>% 
      ggplot(aes(x = factor(week), y = trapcount)) +
      geom_col(aes(fill = factor(species)), size = 3) +
      facet_wrap(~site, scales = "free_y") +
      scale_fill_viridis_d("Species") +
      scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE)) +
      scale_x_discrete(labels = everysecond(wmb$cdcweek)) +
      theme_bw() +
      labs(x = "Week",
           y = "Total Mosquito Count") +
      theme(text=element_text(size=20)) +
      guides(fill = guide_legend(label.theme = element_text(face = "italic")))
  })
  
  
}

shinyApp(ui, server)
