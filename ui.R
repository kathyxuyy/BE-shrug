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
                            dataTableOutput("businesses")
                          )
                        )
               ),  
               
               tabPanel("Location Search",
                        sidebarLayout(
                          sidebarPanel(
                            textInput("search_box", "Type your business here"),
                            textInput("location_box", "Type your location here"),
                            
                            #filters for the map: price, 
                            radioButtons("business_filter", label = "Prices", choices = list("No Preference" = "", "$", "$$", "$$$", "$$$$")),
                            actionButton("location_button", label = "", icon = shiny::icon("search"))
                          ),
                          
                          
                          mainPanel(
                            leafletOutput('myMap', height = "800")
                          )
                        )
               ),
               
               tabPanel("Business Comparison",
                        
                        # inputs at side of page       
                        
                        # sidebarLayout(
                        #   sidebarPanel(
                        #     textInput("name1", "Type business' name here"),
                        #     textInput("name2", "Type business' name here"),
                        #     textInput("locationlocation", "Type your location here"),
                        #     actionButton("compare", label = "", icon = shiny::icon("search"))
                        #   ),
                        #   mainPanel(
                        #     column(12,
                        #     dataTableOutput("test")
                        #     ),
                        #     column(12,
                        #             dataTableOutput("review")
                        #     )
                        #   )
                        # )
                        
                        # inputs at the top of page
                        fluidRow(
                          column(3,
                                 textInput("name1", "Type business' name here")
                          ),
                          column(3,
                                 textInput("locationlocation", "Type your location here")
                          ),
                          column(3,
                                 textInput("name2", "Type business' name here")
                          ),
                          column(1,
                                 actionButton("compare", label = "", icon = shiny::icon("search"))
                          )
                        ),
                        fluidRow(
                          column(6, dataTableOutput("test")),
                          column(6, dataTableOutput("review"))
                        )
               ),
               
               
               tabPanel("Location Analytics",
                        sidebarLayout(
                          sidebarPanel(
                            textInput("search_location", "Enter a location:"),
                            selectInput("factor", "Select the variable you are interested in:", choices = list("price", "rating"))
                          ),
                          mainPanel(
                            plotOutput("analytics")
                          )
                          
                        )         
                        
               )
    )
  )
)