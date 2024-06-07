library(shiny)
library(rvest)
library(dplyr)
library(stringr)
library(janitor)
library(tidyr)
library(lubridate)
library(DT)
library(shinythemes)
library(shinycssloaders)
library(shinyWidgets)
library(ggplot2)
library(readr)
library(weathercan)
library(sf)

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

# get_weather_historical <- weather_dl(station_ids = station_id, interval = "day", start = min(winnipeg_historical$count_date), end = max(winnipeg_historical$count_date))
# 
# get_weather_historical %>% 
#   write.csv("winnipeg_weather_historical.csv")

get_weather_historical <- read_csv("winnipeg_weather_historical.csv")

winnipeg_historical <- winnipeg_historical %>% 
  left_join(get_weather_historical, by = c("count_date" = "date")) %>% 
  mutate(year = year(count_date)) 

# SHAPE ----

# shape <- read_sf("Shape/lfsa000b21a_e.shp")
# # filter(PRNAME == "Manitoba")
# 
# mb_fsa <- read_csv("MB FSAs.csv") %>% 
#   clean_names() %>% 
#   filter(place_name %in% c("Winnipeg", "Headingley", "East Saint Paul", "West Saint Paul"))
# 
# trap_fsa <- read_csv("trap_associated_fsa.csv") %>% 
#   clean_names()

# shape %>% 
#   filter(PRNAME == "Manitoba") %>% 
#   filter(CFSAUID %in% mb_fsa$fsa_code) %>% 
#   filter(!CFSAUID %in% c("R0H", "R3C")) %>% 
#   left_join(trap_fsa, by = c("CFSAUID" = "fsa")) %>% 
#   st_write(., "wpg_shape_data.shp")

shape <- read_sf("Shape/wpg_shape_data.shp")

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
      ),
      mainPanel(
        h3("Map of Mosquito Trap Catches"),
        
        fluidRow(
          
          column(width = 3, uiOutput("map_date_picker_ui")),
        
          column(width = 3,
                 selectInput(
                   "map_region_picker",
                   "Map Type:",
                   choices = c("Winnipeg", "Winnipeg Metro Region"),
                   selected = "Winnipeg",
                 ))

        ),
        
        withSpinner(plotOutput("wpg_map", height = "700px")),
        
        h3("Number of Mosquitoes by Region"),
        
        checkboxGroupInput(
          "date_range_wpg_current",
          "Choose Historical Data Years:",
          choices = min(winnipeg_historical$year):max(winnipeg_historical$year),
          selected = min(winnipeg_historical$year):max(winnipeg_historical$year),
          inline = TRUE
        ),
        
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
        ),

        withSpinner(uiOutput("plotorprint_wpg")),
       
        # Output summary data table
        h3("2024 Data"),
       
       fluidRow(
        column(width = 6, h4("Region Summary"), dataTableOutput("data_table_summary", width = 500)),
        column(width = 6, h4("Raw Data"), dataTableOutput("data_table_raw", width = 500))
       ),
       
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
       
       withSpinner(plotOutput("wpg_hist_fig")),
       
       selectInput(
         "wpg_hist_weather_compare",
         "Choose Weather Comparable",
         choices = c("Mean Temperature", "Max Temperature", "Min Temperature", "Precipitation"),
         selected = NULL
       ),
       
       withSpinner(plotOutput("wpg_hist_fig_weather"))

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
    withSpinner(plotOutput("bdn_hist_fig"))
    
    
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
        
        withSpinner(plotOutput("wmb_hist_fig")),
        
        h3("Trap Counts by Species & Location"),
        
        selectInput(
          "date_range_wmb_species",
          "Choose Year(s):",
          choices = min(wmb$year):max(wmb$year),
          multiple = FALSE
        ),
        
        withSpinner(plotOutput("wmb_hist_fig_species", height = "800px"))
        
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

  ## LOAD MASTER DATA ----
  master_data <- read_csv(url("https://github.com/colebaril/Mosquito_Monitor/blob/main/mosquito_data.csv?raw=TRUE"))
  
  
  
  # LAST UPDATED
  last_updated_not <- max(master_data$date)
  
  # LAST UPDATED NOTIFICATION
  observe({
    showNotification(paste0("Data last updated on ", last_updated_not, ". This is the latest data from the City of Winnipeg."),
                     type = "message", duration = NULL)
  }) 
  
  # SUMMARIES FOR TABLES
  master_data_summary <- master_data %>% 
    summarise(sum = sum(number, na.rm = TRUE),
              avg = mean(number, na.rm = TRUE),
              .by = c("region", "date"))
  
  master_data_summary_out <- master_data %>% 
    filter(region == "Out of City Limits") %>% 
    summarise(sum = sum(number, na.rm = TRUE),
              avg = mean(number, na.rm = TRUE),
              .by = c("region_name", "date"))
  
  # WEATHER ----
  # FOR NOW NOT NEEDED AS STATIC WEATHER DATA IS USED

  # weather <<- readRDS("ywg_weather_history.rds") %>%
  #   mutate(date = as_date(date))
  # 
  # station_id <- stations_search(name = "Winnipeg", interval = "day") %>%
  #   filter(station_name == "WINNIPEG A CS") %>%
  #   select(station_id) %>% pull()
  # 
  # 
  # get_weather_current <- weather_dl(station_ids = station_id, interval = "day", start = min(master_data$date), end = max(master_data$date))
  # 
  # get_weather_historical <- weather_dl(station_ids = station_id, interval = "day", start = min(winnipeg_historical$date), end = max(winnipeg_historical$date))
  # 
  # weather <<- rbind(weather, weather_updated)
  # 
  # weather %>%
  #   write_rds("ywg_weather_history.rds")
  # 
  # print("Winnipeg A Weather data has been updated.")
  
# DATE PICKER REACTIVE ELEMENT FOR MAP
output$map_date_picker_ui <- renderUI({
  airDatepickerInput(inputId = "map_date_input", label = "Select Date", highlightedDates = unique(master_data$date), 
                                                  multiple = FALSE, value = max(master_data$date))
})
  
  
  output$data_table <- DT::renderDataTable({
    DT::datatable(master_data,
                  extensions = "Buttons",
                  options = list(
                    paging = TRUE, 
                    searching = TRUE,
                    dom = "Bfrtip",
                    buttons = c("csv", "excel")
                  ),
                  class = "display") 
  })
  
  
  # WPG DATATABLE ----
  
  output$data_table_summary <- DT::renderDataTable({
    if(input$wpg_data_type == "Winnipeg") {
    master_data_summary %>% 
        filter(region != "Out of City Limits") %>% 
      mutate(avg = round(avg, digits = 1)) %>% 
      rename(`Date` = date,
             `Region` = region,
             `Total` = sum,
             `Average` = avg) %>% 
        DT::datatable(,
                      class = 'cell-border stripe',
                      filter = "top",
                      rownames = FALSE

                      )
      
    } else if(input$wpg_data_type == "Outside City Limits") {
      master_data_summary_out %>% 
        mutate(avg = round(avg, digits = 1)) %>% 
        rename(`Date` = date,
               `Region` = region_name,
               `Total` = sum,
               `Average` = avg) %>% 
        DT::datatable(,
                      class = 'cell-border stripe',
                      filter = "top",
                      rownames = FALSE

        )
    }
  })
  
  output$data_table_raw <- DT::renderDataTable({
    if(input$wpg_data_type == "Winnipeg") {
      master_data %>% 
        filter(region != "Out of City Limits") %>% 
        rename(`Date` = date,
               `Region` = region,
               `Region Name` = region_name,
               `Trap Name` = trap,
               `Trap Count` = number) %>% 
        DT::datatable(,
                      class = 'cell-border stripe',
                      filter = "top",
                      rownames = FALSE
    
        )
      
    } else if(input$wpg_data_type == "Outside City Limits") {
      master_data %>% 
        filter(region == "Out of City Limits") %>% 
        rename(`Date` = date,
               `Region` = region,
               `Region Name` = region_name,
               `Trap Name` = trap,
               `Trap Count` = number) %>% 
        DT::datatable(,
                      class = 'cell-border stripe',
                      filter = "top",
                      rownames = FALSE
                     
        )
    }
  })
  
# WPG FIGURES ----
  ### WPG MAP ----
  output$wpg_map <- renderPlot({
    
    # wpg_shape_data <- shape %>% 
    #   filter(PRNAME == "Manitoba") %>% 
    #   filter(CFSAUID %in% mb_fsa$fsa_code) %>% 
    #   filter(!CFSAUID %in% c("R0H", "R3C")) %>% 
    #   left_join(trap_fsa, by = c("CFSAUID" = "fsa"))
    
    wpg_shape_data <- shape
    
    if(input$map_region_picker == "Winnipeg Metro Region") {
    
    master_data %>% 
      filter(date %in% input$map_date_input) %>%
      full_join(wpg_shape_data, by = c("trap" = "trap_name")) %>% 
      ggplot(aes(geometry = geometry, fill = number)) +
      geom_sf() +
      # geom_sf_text(aes(label = CFSAUID)) +
      theme_void(base_size = 20) +
      scale_fill_viridis_c("Total Mosquitoes") +
      theme(legend.position = "left")
      
    } else if(input$map_region_picker == "Winnipeg") {
      # mutate(region_name = case_when(str_detect(trap, "aa") ~ "Lilyfield",
      #                                str_detect(trap, "bb") ~ "North Perimeter",
      #                                str_detect(trap, "cc") ~ "West St. Paul",
      #                                str_detect(trap, "dd") ~ "East St. Paul",
      #                                str_detect(trap, "ee") ~ "Springfield",
      #                                str_detect(trap, "ff") ~ "Ritchot",
      #                                str_detect(trap, "gg") ~ "MacDonald",
      #                                str_detect(trap, "hh") ~ "Headingly",
      #                                str_detect(trap, "ii") ~ "Rosser",
      
      n_ross <- master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>% 
        filter(trap == "ii") %>% 
        select(number) %>% 
        pull()
      
      n_head <- master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>% 
        filter(trap == "hh") %>% 
        select(number) %>% 
        pull()
      
      n_mac <- master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>% 
        filter(trap == "gg") %>% 
        select(number) %>% 
        pull()
      
      n_ritch <- master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>% 
        filter(trap == "ee") %>% 
        select(number) %>% 
        pull()
      
      n_esp <- master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>% 
        filter(trap == "dd") %>% 
        select(number) %>% 
        pull()
      
      n_wsp <- master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>% 
        filter(trap == "cc") %>% 
        select(number) %>% 
        pull()
      
      n_nper <- master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>% 
        filter(trap == "bb") %>% 
        select(number) %>% 
        pull()
      
      n_springfield <- master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>% 
        filter(trap == "ff") %>% 
        select(number) %>% 
        pull()
      
      n_lilyfield <- master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>% 
        filter(trap == "aa") %>% 
        select(number) %>% 
        pull()
      
      master_data %>% 
        filter(date %in% input$map_date_input) %>%
        # filter(date == "2024-05-27") %>%
        full_join(wpg_shape_data, by = c("trap" = "trap_name")) %>% 
        filter(map_type == "Winnipeg") %>% 
        mutate(binned_number = cut(number, breaks = bins, labels = labels, include.lowest = TRUE)) %>%
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
             subtitle = paste0("Last Updated ", format(Sys.Date(), "%A, %B %d, %Y")),
             caption = "Grey/white zones: no data. Counts for areas out of city limits displayed as text. \nViz & Workflow by Cole Baril | colebaril.ca") +
        theme(legend.position = "left",
              plot.caption = element_text(hjust = 0),
              plot.title = element_text(face = "bold"))
    }
  })
  
  ### WPG FACET ----
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
      scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE), trans = "log1p") +
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
        scale_y_continuous(labels=function(x) format(x, big.mark = ",", scientific = FALSE), trans = "log1p") +
        facet_wrap(~region_name) +
        theme_bw(base_size = 15) +
        labs(x = "Week",
             y = "Total Mosquito Count",
             subtitle = "Current year shown in red. Historical data shown in grey.")
    }
    
    
  })
  
  # IF NO DATA, INDICATE
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
  
  output$wpg_hist_fig <- renderPlot ({
    
    winnipeg_historical %>% 
      filter(year %in% input$date_range_wpg_hist) %>%
      filter(region %in% input$region_wpg_hist) %>% 
      mutate(week = week(count_date)) %>% 
      ggplot(aes(x = factor(week))) +
      geom_jitter(aes(y = number, colour = factor(year)), width = 0.3, size = 3) +
      scale_colour_viridis_d(name = "Year") +
      scale_y_continuous(
        name = "Total Mosquito Count",
        labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
      theme_bw() +
      labs(x = "Week") +
      theme(text = element_text(size = 20))
    
  })
  
  output$wpg_hist_fig_weather <- renderPlot({
    
    if(input$wpg_hist_weather_compare == "Mean Temperature") {
    
    weather_data <- winnipeg_historical %>% 
      distinct(count_date, .keep_all = TRUE)
    
    winnipeg_historical %>% 
      filter(year %in% input$date_range_wpg_hist) %>%
      mutate(week = week(count_date)) %>% 
      ggplot(aes(x = factor(week))) +
      geom_point(aes(y = as.numeric(mean_temp), colour = factor(year)), width = 0.3, size = 3) +
      geom_smooth(data = winnipeg_historical %>% 
                    filter(year %in% input$date_range_wpg_hist) %>%
                    distinct(count_date, .keep_all = TRUE), 
                  aes(y = as.numeric(mean_temp), group = factor(year), colour = factor(year)), se = FALSE) +
      scale_colour_viridis_d(name = "Year") +
      scale_y_continuous(
        name = "Mean Temperature (°C)",
        labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
      theme_bw() +
      labs(x = "Week") +
      theme(text = element_text(size = 20))
    
    } else if(input$wpg_hist_weather_compare == "Max Temperature") {
      
      weather_data <- winnipeg_historical %>% 
        distinct(count_date, .keep_all = TRUE)
      
      winnipeg_historical %>% 
        filter(year %in% input$date_range_wpg_hist) %>%
        mutate(week = week(count_date)) %>% 
        ggplot(aes(x = factor(week))) +
        geom_point(aes(y = as.numeric(max_temp), colour = factor(year)), width = 0.3, size = 3) +
        geom_smooth(data = winnipeg_historical %>% 
                      filter(year %in% input$date_range_wpg_hist) %>%
                      distinct(count_date, .keep_all = TRUE), 
                    aes(y = as.numeric(max_temp), group = factor(year), colour = factor(year)), se = FALSE) +
        scale_colour_viridis_d(name = "Year") +
        scale_y_continuous(
          name = "Max Temperature (°C)",
          labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
        theme_bw() +
        labs(x = "Week") +
        theme(text = element_text(size = 20))
      
    } else if(input$wpg_hist_weather_compare == "Min Temperature") {

      weather_data <- winnipeg_historical %>% 
        distinct(count_date, .keep_all = TRUE)
      
      winnipeg_historical %>% 
        filter(year %in% input$date_range_wpg_hist) %>%
        mutate(week = week(count_date)) %>% 
        ggplot(aes(x = factor(week))) +
        geom_point(aes(y = as.numeric(min_temp), colour = factor(year)), width = 0.3, size = 3) +
        geom_smooth(data = winnipeg_historical %>% 
                      filter(year %in% input$date_range_wpg_hist) %>%
                      distinct(count_date, .keep_all = TRUE), 
                    aes(y = as.numeric(min_temp), group = factor(year), colour = factor(year)), se = FALSE) +
        scale_colour_viridis_d(name = "Year") +
        scale_y_continuous(
          name = "Min Temperature (°C)",
          labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
        theme_bw() +
        labs(x = "Week") +
        theme(text = element_text(size = 20))
      
    } else if(input$wpg_hist_weather_compare == "Precipitation") {
      
      winnipeg_historical %>% 
        filter(year %in% input$date_range_wpg_hist) %>%
        mutate(week = week(count_date)) %>% 
        ggplot(aes(x = factor(week))) +
        geom_point(aes(y = as.numeric(total_precip), colour = factor(year)), width = 0.3, size = 3) +
        geom_smooth(data = winnipeg_historical %>% 
                      filter(year %in% input$date_range_wpg_hist) %>%
                      distinct(count_date, .keep_all = TRUE), 
                    aes(y = as.numeric(total_precip), group = factor(year), colour = factor(year)), se = FALSE) +
        scale_colour_viridis_d(name = "Year") +
        scale_y_continuous(
          name = "Total Precipitation (mm)",
          labels = function(x) format(x, big.mark = ",", scientific = FALSE)) +
        theme_bw() +
        labs(x = "Week") +
        theme(text = element_text(size = 20))
    }
    
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
