#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
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

#### the server function with added polygons
server <- function(input, output, session) {
    # # load in data
    load("Dataset/info523-CVRM_Subset-02.RData")
    CVRM_subset$distlastresidence <- as.character(CVRM_subset$distlastresidence)
    # calculate correct arrest numbers
    CVRM_subset <- CVRM_subset %>%
        group_by(distlastresidence) %>%
        mutate(COUNT_arr = sum(arrest_num))
    
    districts_raw <- sf::read_sf("Dataset/Boundaries - Police Districts (current).geojson")
    
    CVRM_subset1 <- left_join(districts_raw, CVRM_subset, by = c("dist_num" = "distlastresidence"))

    # subset data to remove 31
    CVRM_no31 <- CVRM_subset1 %>%
        group_by(dist_num) %>%
        dplyr::filter(dist_num != "31")
  
    # bins for the number of arrests
    bins <- c(0, 10, 20, 30, 40, 50, 60, 70, Inf)
    
    # color palette
    pal <- colorBin("Blues", domain = CVRM_no31$COUNT_arr, bins = bins)
    
    # labels for the map
    labels <- sprintf(
        "<strong>%s DISTRICT</strong><br/>%g arrests",
        CVRM_no31$dist_label, CVRM_no31$COUNT_arr
    ) %>% lapply(htmltools::HTML)
    
    output$map <- renderLeaflet({
    # leafletProxy("m3") %>% 
         leaflet() %>%
            addTiles() %>%  # Add default OpenStreetMap map tiles
            addMarkers(lng=-87.663045, lat=42.009932, popup="Chicago") %>%
            addMarkers(lng=-87.827286, lat=41.963364, label = "Norridge Village") %>% 
            setView(lng = -87.7539448, lat = 41.8455877, zoom = 11)  %>%
            addPolygons(data = CVRM_no31, stroke = TRUE, smoothFactor = 0.2, fillOpacity = 0.1,
                        fillColor = ~pal(COUNT_arr), color = "white", weight = 1,
                        highlightOptions = highlightOptions(
                            # color = "white", weight = 2, 
                            fillOpacity = 0.7,
                            bringToFront = TRUE),
                        label = labels,
                        labelOptions = labelOptions(
                            style = list("font-weight" = "normal", padding = "3px 8px"),
                            textsize = "15px",
                            direction = "auto")
            ) %>%
        addLegend("bottomleft", pal = pal, values = CVRM_no31$COUNT_arr,
                  title = "Number of arrests",
                  opacity = 1)
    })
}

# integrate the two apps
shinyApp(ui = ui, server = server)
