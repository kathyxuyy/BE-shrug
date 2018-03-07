# ui.R file

library(leaflet)
library(shiny)
library(DT)

shinyUI(
  fluidPage(
    theme = "bootstrap.css", 
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
                                    h3(textOutput("tableInfo"),
                                       tags$style(type="text/css", "#tableInfo { height: 50px; width: 100%; text-align:center; display: block; font-weight: bold; }")
                                    ),
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
                                  column(6, id = "black",
                                         h2(textOutput("bn1")),
                                         htmlOutput("bi1"),
                                         htmlOutput("line"),
                                         div(
                                           textOutput("phone"),
                                           textOutput("bp1")
                                         ),
                                         htmlOutput("line2"),
                                         div(
                                           textOutput("address"),
                                           textOutput("ba1p1"),
                                           textOutput("ba1p3"),
                                           textOutput("ba1p2")
                                         ),
                                         htmlOutput("line6"),
                                         div(
                                           textOutput("distance"),
                                           textOutput("busiDist1")
                                         ),
                                         htmlOutput("line7"),
                                         div(
                                           textOutput("price"),
                                           textOutput("busiPrice1")
                                         ),
                                         htmlOutput("line3"),
                                         div(
                                           textOutput("Average"),
                                           h4(textOutput("star1"))
                                         ),
                                         h3(textOutput("reviews")),
                                         div(
                                           div(
                                             textOutput("reviewtext1"),
                                             htmlOutput("more1"),
                                             tags$br(),
                                             h4(textOutput("reviewStars1")),
                                             tags$br(),
                                             textOutput("reviewName1"),
                                             textOutput("reviewDate1")
                                           ),
                                           htmlOutput("line4"),
                                           div(
                                             textOutput("reviewtext2"),
                                             htmlOutput("more2"),
                                             tags$br(),
                                             h4(textOutput("reviewStars2")),
                                             tags$br(),
                                             textOutput("reviewName2"),
                                             textOutput("reviewDate2")
                                           ),
                                           htmlOutput("line5"),
                                           div(
                                             textOutput("reviewtext3"),
                                             htmlOutput("more3"),
                                             tags$br(),
                                             h4(textOutput("reviewStars3")),
                                             tags$br(),
                                             textOutput("reviewName3"),
                                             textOutput("reviewDate3")
                                           )
                                         )
                                  ),
                                  column(6,
                                         h2(textOutput("bn2")),
                                         htmlOutput("bi2"),
                                         htmlOutput("line8"),
                                         div(
                                           textOutput("phone1"),
                                           textOutput("bp2")
                                         ),
                                         htmlOutput("line9"),
                                         div(
                                           textOutput("address1"),
                                           textOutput("ba2p1"),
                                           textOutput("ba2p3"),
                                           textOutput("ba2p2")
                                         ),
                                         htmlOutput("line10"),
                                         div(
                                           textOutput("distance1"),
                                           textOutput("busiDist2")
                                         ),
                                         htmlOutput("line11"),
                                         div(
                                           textOutput("price1"),
                                           textOutput("busiPrice2")
                                         ),
                                         htmlOutput("line12"),
                                         div(
                                           textOutput("Average1"),
                                           h4(textOutput("star2"))
                                         ),
                                         h3(textOutput("reviews1")),
                                         div(
                                           div(
                                             textOutput("reviewtext4"),
                                             htmlOutput("more4"),
                                             tags$br(),
                                             h4(textOutput("reviewStars4")),
                                             tags$br(),
                                             textOutput("reviewName4"),
                                             textOutput("reviewDate4")
                                           ),
                                           htmlOutput("line13"),
                                           div(
                                             textOutput("reviewtext5"),
                                             htmlOutput("more5"),
                                             tags$br(),
                                             h4(textOutput("reviewStars5")),
                                             tags$br(),
                                             textOutput("reviewName5"),
                                             textOutput("reviewDate5")
                                           ),
                                           htmlOutput("line14"),
                                           div(
                                             textOutput("reviewtext6"),
                                             htmlOutput("more6"),
                                             tags$br(),
                                             h4(textOutput("reviewStars6")),
                                             tags$br(),
                                             textOutput("reviewName6"),
                                             textOutput("reviewDate6")
                                           )
                                         )
                                )
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