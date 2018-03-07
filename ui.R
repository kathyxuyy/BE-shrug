# ui.R file

library(leaflet)
library(shiny)
library(DT)

shinyUI(
  fluidPage(
    #theme = "bootstrap.css", 
    class = "sure",
            includeCSS("style.css"),
            navbarPage("Yelp Business", id = "no", inverse = TRUE,
                       
                       # Creates a tab panel for Business Search
                       tabPanel("Business Search",
                                sidebarLayout(
                                  
                                  sidebarPanel(
                                    textInput("search_input", "Type your search here"),
                                    textInput("location_input", "Type your location here"),
                                    actionButton("search_button", label = "", icon = shiny::icon("search"))
                                    
                                  ),
                                  mainPanel(id = "yes",
                                            dataTableOutput("businesses")
                                  )
                                )
                       ),  
                       
                       # Creates a tab panel for Location Search
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
                       
                       # Creates tab panel for Business Comparison
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
                                  column(6, 
                                         h2(textOutput("bn1")),
                                         htmlOutput("bi1"),
                                         htmlOutput("line"),
                                         textOutput("phone"),
                                         textOutput("bp1"),
                                         htmlOutput("line2"),
                                         textOutput("address"),
                                         textOutput("ba1p1"),
                                         textOutput("ba1p3"),
                                         textOutput("ba1p2"),
                                         htmlOutput("line3"),
                                         textOutput("Average"),
                                         h4(textOutput("star")),
                                         h3(textOutput("reviews")),
                                         textOutput("reviewtext1"),
                                         htmlOutput("more1"),
                                         tags$br(),
                                         h4(textOutput("reviewStars1")),
                                         tags$br(),
                                         textOutput("reviewName1"),
                                         textOutput("reviewDate1")
                                         
                                  ),
                                  column(6, dataTableOutput("review"))
                                )
                       ),
                       
                       # Creates tab panel for Categories
                       tabPanel("Categories",
                                sidebarLayout(
                                  sidebarPanel(
                                    textInput("search_location_categories", "Enter a location:", value = "Seattle"),
                                    actionButton("analysis_button", label = "", icon = shiny::icon("search"))
                                  ),
                                  mainPanel(
                                    plotOutput("analytics")
                                  )
                                )         
                       ),
                       
                       # Creates tab panel for Popular Restaurants
                       tabPanel("Popular Restaurants",
                                sidebarLayout(
                                  sidebarPanel(
                                    textInput("search_location", "Enter a location:", value = "Seattle"),
                                    radioButtons("factor", label = "", choices = list("rating" = 2, "price" = 3)),
                                    actionButton("popular_button", label = "", icon = shiny::icon("search"))
                                  ),
                                  mainPanel(
                                    plotOutput("popular")
                                  )
                                )         
                       )
            )
  )
)