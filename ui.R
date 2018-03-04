# ui.R file

library(leaflet)
library(shiny)
library(DT)

shinyUI(
  fluidPage(
    includeCSS("style.css"),
    navbarPage("Yelp Business",
        tabPanel("Business Search",
          sidebarLayout(
          
          sidebarPanel(
            textInput("search_input", "Type your search here"),
            textInput("location_input", "Type your location here"),
            actionButton("search_button", label = "", icon = shiny::icon("search"))
            
          ),
            mainPanel(
              DT::dataTableOutput("businesses")
            )
          )
        ),  
          
      tabPanel("Location Search",
        sidebarLayout(
          sidebarPanel(
            textInput("search_box", "Type your business here"),
            textInput("location_box", "Type your location here"),
            actionButton("location_button", label = "", icon = shiny::icon("search"))
          ),
        
        
        mainPanel(
          leafletOutput('myMap', height = "800")
        )
      )
    )
    )
  )
)

    
