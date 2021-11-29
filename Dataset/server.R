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
library(leaflet)
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


# load in the dataset
load("Dataset/info523-CVRM_Subset-02.RData")
CVRM_subset$riskscore <- factor(CVRM_subset$riskscore, 
                                levels = c("VERY HIGH", "HIGH", "MODERATE", "LOW", "VERY LOW"))

## merge in arrests onto the sf object districts_raw
CVRM_subset$distlastresidence <- as.character(CVRM_subset$distlastresidence)

# police districts
districts_geojson <- "Dataset/Boundaries - Police Districts (current).geojson"
districts_raw <- sf::read_sf(districts_geojson)

# districs <- merge(districts_raw, CVRM_sample, by=, all.x=TRUE)
CVRM_subset1 <- left_join(districts_raw, CVRM_subset, by = c("dist_num" = "distlastresidence"))

CVRM_no31 <- CVRM_subset1 %>% 
    group_by(dist_num) %>% 
    dplyr::filter(dist_num != "31")

# for no 31
# try choropleth for non 31
CVRM_no31 <- CVRM_no31 %>% 
    group_by(arrest_num) %>% 
    mutate(COUNT = n())

bins <- c(0, 10, 20, 30, 40, 50, 60,70,80,90, 100, 200, 300, Inf)
pal <- colorBin("Oranges", domain = CVRM_no31$COUNT, bins = bins)

# add custom label info
labels <- sprintf(
    "<strong>%s DISTRICT</strong><br/>%g arrests",
    CVRM_no31$dist_label, CVRM_no31$COUNT
) %>% lapply(htmltools::HTML)

m3 <- leaflet(CVRM_no31) %>%
    addTiles() %>%  # Add default OpenStreetMap map tiles
    # addProviderTiles(providers$CartonDB.Position) %>% 
    addMarkers(lng=-87.663045, lat=42.009932, popup="Chicago") %>% 
    setView(lng = -87.66, lat = 42, zoom = 11) %>% 
    addPolygons(stroke = FALSE, smoothFactor = 0.2, opacity = 0.2, fillOpacity = 0.2,
                fillColor = ~pal(COUNT), 
                highlightOptions = highlightOptions(color = "#666", weight = 2, fillOpacity = 0.1,
                                                    bringToFront = TRUE),
                label = labels,
                labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")
    ) %>% 
    addLegend("bottomright", pal = pal, values = ~COUNT,
              title = "Number of arrests",
              opacity = 1)

#### the server function 
server <- function(input, output, session) {

    # # load in data
    # load("Dataset/info523-CVRM_Subset-02.RData")
    # CVRM_subset$distlastresidence <- as.character(CVRM_subset$distlastresidence)
    # 
    # districts_geojson <- "Dataset/Boundaries - Police Districts (current).geojson"
    # districts_raw <- sf::read_sf(districts_geojson)
    # 
    # # districs <- merge(districts_raw, CVRM_sample, by=, all.x=TRUE)
    # CVRM_subset1 <- left_join(districts_raw, CVRM_subset, by = c("dist_num" = "distlastresidence"))
    # 
    # CVRM_no31 <- CVRM_subset1 %>% 
    #     group_by(dist_num) %>% 
    #     dplyr::filter(dist_num != "31")
    # 
    # # for no 31
    # # try choropleth for non 31
    # CVRM_no31 <- CVRM_no31 %>% 
    #     group_by(arrest_num) %>% 
    #     mutate(COUNT = n())
    # 
    # bins <- c(0, 10, 20, 30, 40, 50, 60,70,80,90, 100, 200, 300, Inf)
    # pal <- colorBin("Oranges", domain = CVRM_no31$COUNT, bins = bins)
    # 
    labels <- reactive({sprintf(
        "<strong>%s DISTRICT</strong><br/>%g arrests",
        CVRM_no31$dist_label, CVRM_no31$COUNT) %>%
            lapply(htmltools::HTML)
    })
    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles() %>%  # Add default OpenStreetMap map tiles
            # addProviderTiles(providers$CartonDB.Position) %>% 
            addMarkers(lng=-87.663045, lat=42.009932, popup="Chicago") %>%
            setView(lng = -87.66, lat = 42, zoom = 11) 
        # %>%
        #     addPolygons(stroke = FALSE, smoothFactor = 0.2, opacity = 0.2, fillOpacity = 0.2,
        #                 fillColor = ~pal(COUNT),
        #                 highlightOptions = highlightOptions(color = "#666", weight = 2, fillOpacity = 0.1,
        #                                                     bringToFront = TRUE),
        #                 label = labels,
        #                 labelOptions = labelOptions(
        #                     style = list("font-weight" = "normal", padding = "3px 8px"),
        #                     textsize = "15px",
        #                     direction = "auto")
        #     ) %>%
            # addLegend("bottomright", pal = pal, values = ~COUNT,
            #           title = "Number of arrests",
            #           opacity = 1)
    })
}

# integrate the two apps
shinyApp(ui = ui, server = server)
