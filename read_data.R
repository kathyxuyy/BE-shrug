source("key.R")


library(httr)
library(jsonlite)
library(dplyr)
library(maps)
library(mapproj)
library(ggplot2)
library(leaflet)

base_yelp_url <- "https://api.yelp.com/v3/"

# basic business data
path = "businesses/search"
query.params = list(term = "Chinese", location = "San fransisco")
response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
body <- content(response, "text")
data <- fromJSON(body)

# turns data from a list into a DF
compressed <- flatten(data[[1]]) %>% select(-id, -categories, -location.display_address, -categories, -transactions)
compressed$image_url <- paste("<img-src> ='", compressed$image_url, "'", sep = "")
ggplot(data = compressed, mapping = aes(x = coordinates.longitude, y = coordinates.latitude, color=rating)) +
  geom_point()
  coord_map()

  r_colors <- rgb(t(col2rgb(colors()) / 255))
  names(r_colors) <- colors()
  
  #mymap = leaflet()
  #mymap = addTiles(mymap)
  #mymap = setView(mymap, lng = 78.0419, lat = 27.1750, zoom = 15)
  
  
  
  
  
  