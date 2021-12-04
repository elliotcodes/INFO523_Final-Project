# Elliot Truslow, Jung Mee Park
# INFO523 Data Mining and Discovery
# November 22, 2021
# Final Project: Shiny App
# tag: INFO523_HW3 / Code for Shiny App UI / ELT 2021-11-22

## ----> Getting Started

# Clear workspace
rm(list=ls())

# Setting working directory
setwd("~/Desktop/Fall 2021/INFO523/Final Project/R Files")

# Confirming directory change
getwd()

# Call packages
library(shiny)
library(shinydashboard)
library(leaflet)
library(RColorBrewer)
library(tidyverse)
library(stringr)
library(sf)
library(httr)
library(magrittr)
library(pacman)
library(lubridate)
library(dplyr)
library(rjson)
library(jsonlite)
library(rgdal)
library(RCurl)
library(sp)
library(htmlwidgets)
library(htmltools)
library(data.table)
library(shiny.semantic)
library(plotly)
library(DT)
library(bslib)
library(boot)
library(shinythemes)

## ----> SERVER CODE <---- #####################################################
#                                                                              #
#   This is the server logic of a Shiny web application. You can run the       #
#   application by clicking 'Run App' above.                                   #
#                                                                              #
#   Find out more about building applications with Shiny here:                 #
#                                                                              #
#   http://shiny.rstudio.com/                                                  #
#                                                                              #
################################################################################

#### Below is the server function with added polygons

## Create server function
server <- function(input, output, session) {
  # # load in data
  load("info523-CVRM_Subset-02.RData")
  CVRM_subset$distlastresidence <- as.character(CVRM_subset$distlastresidence)
  # calculate correct arrest numbers
  CVRM_subset <- CVRM_subset %>%
    group_by(distlastresidence) %>%
    mutate(COUNT_arr = sum(arrest_num))
  
  # map districts with geojson (geographic features and nonspatial attributes)
  districts_raw <- sf::read_sf("Boundaries - Police Districts (current).geojson")
  
  # connect district of last residence and total # of arrests per district
  CVRM_subset1 <- left_join(districts_raw, CVRM_subset, by = c("dist_num" = "distlastresidence"))
  
  # subset data to remove district 31 (represents suburban Cook County)
  CVRM_no31 <- CVRM_subset1 %>%
    group_by(dist_num) %>%
    dplyr::filter(dist_num != "31")
  
  # create bins for the number of arrests (# bins = 9)
  bins <- c(0, 10, 20, 30, 40, 50, 60, 70, Inf)
  
  # assign color palette to polygons (districts on map)
  pal <- colorBin("Blues", domain = CVRM_no31$COUNT_arr, bins = bins)
  
  # label the map
  labels <- sprintf(
    "<strong>%s DISTRICT</strong><br/>%g arrests",
    CVRM_no31$dist_label, CVRM_no31$COUNT_arr
  ) %>% lapply(htmltools::HTML)
  
  # render the map using Leaflet
  output$map <- renderLeaflet({
    # leafletProxy("m3") %>% 
    leaflet() %>%
      addTiles() %>%  # Add default OpenStreetMap map tiles
      addMarkers(lng=-87.663045, lat=42.009932, popup="Chicago") %>%
      addMarkers(lng=-87.827286, lat=41.963364, label = "Norridge Village") %>% # independent township
      setView(lng = -87.7539448, lat = 41.8455877, zoom = 11)  %>%
      addPolygons(data = CVRM_no31, stroke = TRUE, smoothFactor = 0.2, fillOpacity = 0.1,
                  fillColor = ~pal(COUNT_arr), color = "white", weight = 1, # palette based on total number of arrests
                  highlightOptions = highlightOptions(
                    # color = "white", weight = 2, # give the districts some borders
                    fillOpacity = 0.7,
                    bringToFront = TRUE),
                  label = labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")
      ) %>%
      addLegend("bottomleft", pal = pal, values = CVRM_no31$COUNT_arr, # labeling the legend (shows 'blues' palette)
                title = "Number of arrests",
                opacity = 1)
  })
}

## ----> UI CODE <---- #########################################################
#                                                                              #
#   This is the user interface logic of a Shiny web application. You can       #
#   run the application by clicking 'Run App' above.                           #
#                                                                              #
#   Find out more about building applications with Shiny here:                 #
#                                                                              #
#   http://shiny.rstudio.com/                                                  #
#                                                                              #
################################################################################

## Code the UI components
ui <- fluidPage(
  theme = shinytheme("paper"),
  navbarPage("Strategic Subjects",
                        
            # --->  Data Page
                        tabPanel("Map",
                                 # side bar code
                                 sidebarLayout(
                                   sidebarPanel(
                                     helpText("The map to the right shows police districts in Chicago, IL. Their numbers include 1-12, 14-20, 22, and 25. District 31 data consist of arrests occuring in suburban Cook County, IL (outside the Chicago City limits)."),
                                   ),
                                 # code for main panel where map goes
                                 mainPanel(
                                   h5("Chicago Police Districts"),
                                   p("The darker the gradiant, the higher the number of arrests in a given district."),
                                   # Connects with Leaflet server code to display map
                                   leafletOutput(outputId = "map", width="100%", height = "100%")
                                 )
                                 )
                        ),
                     
            # --->  About Page
                        tabPanel("About this Project",
                                 fluidRow(
                                   column(9,
                                          # pull in an R Markdown file with background, methods, relevance, etc.
                                          includeMarkdown("About-This-Project.Rmd")
                                 ))
                                 ),

            # --->  Implications Page
                        tabPanel("Implications", 
                                fluidRow(
                                   column(9,
                                  # pull in an R Markdown file with info on racialized policing
                                  includeMarkdown("Implications.Rmd"),
                        
                       ))
            ),

            # --->  References Page
                    tabPanel("References", 
                             fluidRow(
                               column(9,
                                      # pull in an R Markdown file with references
                                      includeMarkdown("Implications.Rmd"),
                                      
                               ))
                    ),
))

# Integrate the ui and server to run app
shinyApp(ui = ui, server = server)

# Click "Run App" button in top right corner
