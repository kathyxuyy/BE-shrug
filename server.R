# server.R file

source("read_data.R")
library(dplyr)
library(DT)

function(input, output) {
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
       compress$
       output$businesses <- DT::renderDataTable(compress)
       #input$search_input
      
  })
  
}