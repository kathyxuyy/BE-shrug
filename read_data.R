source("key.R")

library(httr)
library(jsonlite)
library(dplyr)

base_yelp_url <- "https://api.yelp.com/v3/"

# basic business data
path = "businesses/search"
query.params = list(term = "Chinese", location = "San fransisco")
response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
body <- content(response, "text")
data <- fromJSON(body)

# turns data from a list into a DF
compressed <- flatten(data[[1]]) %>% select(-id, -categories, -location.display_address, -categories, -transactions, -coordinates.latitude, -coordinates.longitude)
compressed$image_url <- paste("<img-src> ='", compressed$image_url, "'", sep = "")

