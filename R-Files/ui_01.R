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

# Load Shiny
library(shiny)
library(bslib)

## ----> Server code (filler to test UI pieces)

server = function(input, output, session) {}


## ----> UI code

ui <- fluidPage(
  theme = bs_theme(version = 5, bootswatch = "litera"),
  navbarPage("INFO523 Final Project",
                        
             
            # --->  Data Page
                        tabPanel("Data",
                                 sidebarLayout(
                                   sidebarPanel(
                                     radioButtons("jurisdiction", "Jurisdiction",
                                                  c("Suburban Cook County"="p", "Chicago City"="l")
                                   ),
                                   selectInput("polDistrict", "Police District", c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "14", "15", "16", "17", "18", "19", "20", "22", "24", "25", "31"))
                                 ),
                                 mainPanel(
                                   h5("Maybe the map can go here."),
                                   p("As of now, the sidebar is not reactive (e.g., selecting 'county' doesn't change the dropdown list)."),
                                   # Map from server code can go here
                                   plotOutput("plot") # this is just filler code for right now
                                 )
                                 )
                        ),
                     
             
             
                     
            # --->  About Page
                        tabPanel("About this Project", #Markdown file with info on data & project
                                 fluidRow(
                                   column(12,
                                          includeMarkdown("Test_MarkdownFile.Rmd")
                                 ))
                                 ),

             
             
             
            # --->  Implications Page
                        tabPanel("Implications",
                                 mainPanel(
                                   h4("Implications"),
                                   p("this page will discuss some implications of the data and why this topic matters.")
                                 )
                                 ),
                              # Include text here highlighting info about race, police violence, tech, etc.
                 
             
             
             
            # --->  References Page
                        tabPanel("References",
                                 sidebarLayout(
                                   sidebarPanel(
                                     helpText("This page will contain references and resources related to the project."),
                                   ),
                                 mainPanel(
                                   h5("References"),
                                   p("Here are some references.")
                                   )
                                 )
                        )
                                  # Include references and links for additional information
))

# Run the app
shinyApp(ui=ui, server=server)

