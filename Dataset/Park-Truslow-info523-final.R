### Jung Mee Park
### jmpark@arizona.edu
### INFO 523-final project
### 2021-22-11

# load libraries
library(shiny)
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

options(digits = 3)
set.seed(1234)
theme_set(theme_minimal())

# set working directory
setwd("~/Documents/INFO 523 fall 2021/practice scripts/INFO-523-final-project/INFO523_Final-Project-main/Dataset")

# Load in CVRM sample (.csv)
CVRM_sample <- read.csv("CVRM_Subset.csv", header = TRUE)
CVRM_sample <- CVRM_sample[,-1]

# https://github.com/aneesa-noorani/R_Shiny_Chicago_Crime/blob/master/Chicago_Crimes_Shiny.R
table(CVRM_sample$riskscore)
CVRM_sample$riskscore <- factor(CVRM_sample$riskscore, 
                                levels = c("VERY HIGH", "HIGH", "MODERATE", "LOW", "VERY LOW"))

# Police Districts
# read a geoJson file
setwd("~/Documents/INFO 523 fall 2021/practice scripts/INFO-523-final-project/INFO523_Final-Project-main/Dataset/Boundaries - Police Districts (current)")
districts_geojson <- "Boundaries - Police Districts (current).geojson"
districts_raw <- sf::read_sf(districts_geojson)
districts_raw

# add to leaflet map of Chicago
m <- leaflet(districts_raw) %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=-87.663045, lat=42.009932, popup="Chicago") %>% 
  setView(lng = -87.66, lat = 42, zoom = 11) %>% 
  addPolygons(weight = 2, smoothFactor = 0.5, opacity = 1, 
                          fillOpacity = 0.5,
                          highlightOptions = highlightOptions(color = "white", weight = 2,
                                                              bringToFront = TRUE))

m

## merge in arrests

