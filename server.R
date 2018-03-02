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
       output$plot <- renderPlot({
         p <- ggplot(data = compress, mapping = aes(x = coordinates.longtitudes, y = coordinates.latitudes)) +
             coord_map()
       })
       #input$search_input
       points <- eventReactive(input$recalc, {
         cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
       }, ignoreNULL = FALSE)
       
       mapStates = map("state", fill = TRUE, plot = FALSE)
      
       
       output$mymap <- renderLeaflet({
         test_map <- leaflet(data = mapStates) %>% addTiles() %>%
           addPolygons(fillColor = topo.colors(67, alpha = NULL), stroke = FALSE)
        return(us_map %>% addProviderTiles(providers$Stamen.TonerLite,
                                       options = providerTileOptions(noWrap = TRUE)
        ) %>%
          addMarkers(data = points()))
       })
  })
  
}