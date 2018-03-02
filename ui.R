# ui.R file

library(shiny)
library(DT)

shinyUI(
  fluidPage(
    
    # Would like to implement navbarpage, would provide for easy navigation
    
    navbarPage("Business",
                      tabPanel("Business Search", 
                        titlePanel("Yelp Business"),
                             
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
                      tabPanel("Component 2"),
                      tabPanel("Component 3")
    )
  )
)
    
