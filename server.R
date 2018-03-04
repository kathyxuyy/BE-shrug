  # server.R file

source("read_data.R")
library(dplyr)
library(DT)
library(ggplot2)
library(maps)
library(mapproj)
library(leaflet)


function(input, output, session){
  observeEvent(input$search_button, {
    base_yelp_url <- "https://api.yelp.com/v3/"
    path = "businesses/search"
    query.params = list(term = input$search_input, location = input$location_input)
    response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    business_data <- fromJSON(body)
    
    # this line makes it so the data table can be printed without altering the values in these columns
    # they are normally in a form of a list and idk how to change them to string, to be fixed eventually
    compress <- flatten(business_data[[1]]) %>% select(-id, -categories, -location.display_address, -categories, -transactions, -coordinates.latitude, -coordinates.longitude)
    compress$image_url <- paste("<img src='", compress$image_url, "' height = '60'</img>", sep = "")
    output$businesses <- DT::renderDataTable(compress, escape = FALSE)
  
    # mapStates = map("state", fill = TRUE, plot = FALSE)
    
  })
  
  map <- leaflet() %>% addTiles() %>% setView(-101.204687, 40.607628, zoom = 3)
  output$myMap <- renderLeaflet(map)
  
  observeEvent(input$location_button, {
    path = "businesses/search"
    query.params = list(term = input$search_box, location = input$location_box)
    response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    specific_data <- fromJSON(body)
    region <- specific_data[[3]]
    center <- region[[1]]
    
    business_frame <- flatten(specific_data[[1]])
    print(str(business_frame))
    output$myMap <- renderLeaflet(map %>% 
                                    setView(center[[1]],center[[2]], zoom = 13) %>% 
                                    addMarkers(lng = business_frame$coordinates.longitude, 
                                              lat = business_frame$coordinates.latitude, label = business_frame$name))
  
  })
  
}