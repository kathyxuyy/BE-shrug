# ui.R file

library(leaflet)
library(shiny)
library(DT)

shinyUI(
  fluidPage(theme = "bootstrap.css", class = "sure",
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
                                    radioButtons("business_filter", label = "Prices", choices = list("No Preference" = "", "$ (less than $10)", "$$ (between $11 and $30)", "$$$ (between $31 and $60)", "$$$$ (more than $61)")),
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
                                         textOutput("phone"),
                                         textOutput("bp1"),
                                         textOutput("address"),
                                         textOutput("ba1p1"),
                                         textOutput("ba1p3"),
                                         textOutput("ba1p2"),
                                         h3(textOutput("star"))
                                  ),
                                  column(6, dataTableOutput("test"))
                                )
                       ),
                       
                       # Creates tab panel for top 6 categories
                       tabPanel("Top 6 Categories",
                                sidebarLayout(
                                  sidebarPanel(
                                    textInput("search_location", "Enter a location:", value = "Seattle"),
                                    actionButton("analysis_button", label = "", icon = shiny::icon("search"))
                                  ),
                                  mainPanel(
                                    plotOutput("analytics")
                                  )
                                  
                                )         
                                
                       ),
                       
                       # Creates tab panel for Most Popular
                       tabPanel("Most Popular",
                                sidebarLayout(
                                  sidebarPanel(
                                    textInput("search_location", "Enter a location:", value = "Seattle"),
                                    actionButton("analysis_button", label = "", icon = shiny::icon("search"))
                                  ),
                                  mainPanel(
                                    plotOutput("popularity")
                                  )
                                  
                                )         
                                
                       )
            )
  )
)
