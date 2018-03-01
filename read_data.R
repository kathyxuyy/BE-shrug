source("key.R")

library(httr)
library(jsonlite)
base_yelp_url <- "https://api.yelp.com/v3/"

# basic business data
path = "businesses/search"
query.params = list(location = "Seattle")
response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json(), encoding = "UTF-8")
body <- content(response, "text")
data <- fromJSON(body)

# turns data from a list into a DF
compressed <- data[[1]]
