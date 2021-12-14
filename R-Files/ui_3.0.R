# Elliot Truslow, Jung Mee Park
# INFO523 Data Mining and Discovery
# December 5, 2021
# Final Project: Shiny App
# tag: INFO523_HW3 / ui code v3.0 / ELT 2021-12-05

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
                          h5(strong("Chicago Police Districts")),
                          p("The darker the gradiant, the higher the number of arrests in a given district. n = 1000"),
                          # Connects with Leaflet server code to display map
                          leafletOutput(outputId = "map", width="100%", height = 700)
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
             
             # --->  Resources Page
             tabPanel("Resources", 
                      fluidRow(
                        column(9,
                               # pull in an R Markdown file with references
                               includeMarkdown("Resources.Rmd"),
                               
                        ))
             ),
  ))

# Integrate the ui and server to run app
shinyApp(ui = ui, server = server)


# Combine with server code in order to execute the Shiny app
# Click 'Run App' in top right corner