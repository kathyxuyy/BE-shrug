# ui.R file

library(leaflet)
library(shiny)
library(DT)

shinyUI(
  fluidPage(
    
    # Would like to implement navbarpage, would provide for easy navigation
    
    navbarPage("Yelp Business App",
      tabPanel("Business Search", 
        titlePanel("Business Search from Location"),
             
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
      
      # panel for plotting information related to business
      tabPanel("Plotting Stuff?",
        "hi",
        leafletOutput("mymap"),
        actionButton("recalc", "New points")         
      ),
      
      
      tabPanel("Review Search",
        textInput("review_input", "Enter a business to find reviews on"),     
        actionButton("review_button", label = "", icon = shiny::icon("search"))
      )
    )
  )
)
    
