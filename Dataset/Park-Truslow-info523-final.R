### Jung Mee Park
### jmpark@arizona.edu
### INFO 523-final project
### 2021-22-11

# load libraries
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

options(digits = 3)
set.seed(1234)
theme_set(theme_minimal())

# set working directory
# setwd("~/Documents/INFO 523 fall 2021/practice scripts/INFO-523-final-project/INFO523_Final-Project-main/Dataset")

# load the dataset
load("~/Documents/INFO 523 fall 2021/practice scripts/INFO-523-final-project/INFO523_Final-Project-main/Dataset/info523-CVRM_Subset-02.RData")

# # Load in CVRM sample (.csv)
# CVRM_sample <- read.csv("CVRM_Subset.csv", header = TRUE)
# CVRM_sample <- CVRM_sample[,-1]

# https://github.com/aneesa-noorani/R_Shiny_Chicago_Crime/blob/master/Chicago_Crimes_Shiny.R
table(CVRM_subset$riskscore)
CVRM_subset$riskscore <- factor(CVRM_subset$riskscore, 
                                levels = c("VERY HIGH", "HIGH", "MODERATE", "LOW", "VERY LOW"))

# look at CVRM breakdown
summary(CVRM_subset)
table(CVRM_subset$distlastresidence)

# Police Districts
# read a geoJson file
setwd("~/Documents/INFO 523 fall 2021/practice scripts/INFO-523-final-project/INFO523_Final-Project-main/Dataset/Boundaries - Police Districts (current)")
districts_geojson <- "Boundaries - Police Districts (current).geojson"
districts_raw <- sf::read_sf(districts_geojson)
districts_raw

# add to leaflet map of Chicago
m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=-87.663045, lat=42.009932, popup="Chicago") %>% 
  setView(lng = -87.66, lat = 42, zoom = 11) %>% 
  addPolygons(data = districts_raw, weight = 2, smoothFactor = 0.5, opacity = 1, 
                          fillOpacity = 0.5,
                          highlightOptions = highlightOptions(color = "white", weight = 2,
                                                              bringToFront = TRUE)) %>% 
  # addCircleMarkers() %>% 
  addProviderTiles(providers$CartonDB.Position)

m

## merge in arrests onto the sf object districts_raw
CVRM_subset$distlastresidence <- as.character(CVRM_subset$distlastresidence)
# districs <- merge(districts_raw, CVRM_sample, by=, all.x=TRUE)
CVRM_subset1 <- left_join(districts_raw, CVRM_subset, by = c("dist_num" = "distlastresidence"))
# different joins add in different rows if necessary. 
# 3 times 31 creates a super large join

# change arrest num into a numeric
CVRM_subset1$arrest_num <- as.numeric(CVRM_subset1$arrest_num)

pal <- colorNumeric(
  palette = "RdYlBu",
  domain = CVRM_subset1$arrest_num
)

# add a legend using number of arrests
m2 <- leaflet(CVRM_subset1) %>% 
  addMarkers(lng=-87.663045, lat=42.009932, popup="Chicago") %>% 
  setView(lng = -87.66, lat = 42, zoom = 11) %>% 
  addTiles()

m2 %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.2, fillOpacity = .5,
              color = ~pal(arrest_num)) %>%
  addLegend("bottomright", pal = pal, values = ~arrest_num,
            title = "Number of arrests",
            opacity = 1)

m2
# add the choropleths
CVRM_subset1 <- CVRM_subset1 %>% 
  group_by(dist_num) %>% 
  mutate(COUNT = n())
# https://stackoverflow.com/questions/68728154/leaflet-map-error-in-polygondata-defaultdata-dont-know-how-to-get-path-dat
bins <- c(0, 10, 20, 30, 40, 50, 100, 200, 300, 400, 500, 1000, Inf)
pal <- colorBin("Set3", domain = CVRM_subset1$COUNT, bins = bins)

# add custom label info
labels <- sprintf(
  "<strong>%s</strong><br/>%g arrests",
  CVRM_subset1$dist_label, CVRM_subset1$COUNT
) %>% lapply(htmltools::HTML)


m2 <- leaflet(CVRM_subset1) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  # addProviderTiles(providers$CartonDB.Position) %>% 
  addMarkers(lng=-87.663045, lat=42.009932, popup="Chicago") %>% 
  setView(lng = -87.66, lat = 42, zoom = 11) %>% 
  addPolygons(opacity = 0.1,
              fillColor = ~pal(COUNT), 
              highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE),
              label = labels,
              labelOptions = labelOptions(
                style = list("font-weight" = "normal", padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")
              )

# %>%
  # addPolygons(data = districts_raw, weight = 2, smoothFactor = 0.5, opacity = 0,
  #             fillOpacity = 0,
  #             highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE))

m2
# Error in cut.default(x, binsToUse, labels = FALSE, include.lowest = TRUE,  : 
#                        'x' must be numeric
# leaflet(CVRM_subset1) %>% addTiles() %>% 
#   addPolygons()

# Error in pointData.default(data) : 
# Don't know how to get location data from object of class leaflet,htmlwidget

### add circles
m2 <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=-87.663045, lat=42.009932, popup="Chicago") %>% 
  setView(lng = -87.66, lat = 42, zoom = 11) %>% 
  addPolygons(data = districts_raw, weight = 2, smoothFactor = 0.5, opacity = 0, 
              fillOpacity = 0.5,
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE)) %>% 
  addCircles(data = CVRM_sample)


# add a marker
m %>% addMarkers(lng=-87.6, lat=44.10, label = "Pop Up")

