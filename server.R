# server.R file

library(dplyr)
library(DT)
library(ggplot2)
library(maps)
library(mapproj)
library(ggmap)
library(leaflet)
library(httr)
library(jsonlite)

source("key.R")

function(input, output, session){
  base_yelp_url <- "https://api.yelp.com/v3/"
  observeEvent(input$search_button, {
    path = "businesses/search" 
    query.params = list(term = input$search_input, location = input$location_input, limit = 50)
    response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    business_data <- fromJSON(body)
    
    # this line makes it so the data table can be printed without altering the values in these columns
    # they are normally in a form of a list and idk how to change them to string, to be fixed eventually
    compress <- flatten(business_data[[1]]) %>% select(-id, -is_closed, -categories, -location.display_address, -categories, -transactions, -coordinates.latitude, -coordinates.longitude, -distance, -display_phone)
    compress$image_url <- paste("<img src='", compress$image_url, "' height = '60'</img>", sep = "")
    compress$url <- paste0("<a href='", compress$url, "' class = 'button'>Website</a>")
    
    # combine addresses to make clean looking address column
    compress$address <- paste0(compress$location.address1, "," , compress$location.city, ", ", compress$location.state, ", ", compress$location.zip_code, ", ", compress$location.country) 
    
    compress <- select(compress,-location.address1, -location.address2, -location.city, -location.state, -location.zip_code, -location.address3, -location.country)
    
    
    # cleaning up coumn titles:
    colnames(compress) <- c("Name", "Image", "Yelp Link", "Review Count", "Rating", "Price", "Phone", "Address")
    
    output$businesses <- renderDataTable(DT::datatable(compress, escape = FALSE, selection = "none"))
    
  })
  
  map <- leaflet() %>% addTiles() %>% setView(-101.204687, 40.607628, zoom = 3)
  output$myMap <- renderLeaflet(map)
  
  business_frame <- data.frame()
  center <- vector("list")
  
  observeEvent(input$location_button, {
    path = "businesses/search"
    query.params = list(term = input$search_box, location = input$location_box)
    response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    specific_data <- fromJSON(body)
    region <- specific_data[[3]]
    center <- region[[1]]
    
    business_frame <- flatten(specific_data[[1]])
    
    if (input$business_filter != "") {
      business_frame <- filter(business_frame, price == input$business_filter)
    }
    if (nrow(business_frame) == 0) {
      view_city <- geocode(input$location_box)
      output$myMap <- renderLeaflet(map %>% setView(view_city[[1]], view_city[[2]], zoom = 13))
    } else {
      output$myMap <- renderLeaflet(map %>% 
                                      setView(center[[1]],center[[2]], zoom = 13) %>% 
                                      addMarkers(lng = business_frame$coordinates.longitude, 
                                                 lat = business_frame$coordinates.latitude, icon=greenLeafIcon, label = business_frame$name))
    }  
    
    getColor <- function(business_frame) {
      sapply(business_frame$rating, function(rating) {
        if(rating >= 4.5) {
          "http://leafletjs.com/examples/custom-icons/leaf-green.png"
        }else if(rating >=3.5 ) {
          "http://leafletjs.com/examples/custom-icons/leaf-orange.png"
        } else {
          "http://leafletjs.com/examples/custom-icons/leaf-red.png"
        } })
    }
    
    greenLeafIcon <- makeIcon(
      iconUrl = getColor(business_frame),
      iconWidth = 38, iconHeight = 95,
      iconAnchorX = 22, iconAnchorY = 94,
      shadowUrl = "http://leafletjs.com/examples/custom-icons/leaf-shadow.png",
      shadowWidth = 50, shadowHeight = 64,
      shadowAnchorX = 4, shadowAnchorY = 62
    )
    
  })
  
  observeEvent(input$compare, {
    base_yelp_url <- "https://api.yelp.com/v3/"
    path = "businesses/search"
    query.params = list(term = input$name1, location = input$locationlocation, limit = 1)
    response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    business_data <- fromJSON(body)
    
    compress <- flatten(business_data[[1]]) %>% select(-categories, -location.display_address, -categories, -transactions, -coordinates.latitude, -coordinates.longitude)
    compress$image_url <- paste("<img src='", compress$image_url, "' height = '250'</img>", sep = "")
    compress$url <- paste0("<a href='", compress$url, "' class = 'button'>Website</a>")
    output$test <- renderDataTable(DT::datatable(compress, escape = FALSE, selection = "none"))
    output$bn1 <- renderText(compress$name)
    output$bi1 <- renderText(compress$image_url)
    # output$bp1 <- renderText(paste("Phone:", compress$display_phone))
    output$address <- renderText("Address:")
    output$phone <- renderText("Phone:")
    star_rate <- ""
    for(i in 1:compress$rating){
      star_rate <- paste(star_rate, "*", sep = "")
    }
    if(compress$rating %% 1 == 0.5){
      star_rate <- paste(star_rate, ".5", sep = "")
    }
    output$star <- renderText(star_rate)
    output$bp1 <- renderText(compress$display_phone)
    output$ba1p1 <- renderText(compress$location.address1)
    output$ba1p3 <- renderText(paste(compress$location.address2, compress$location.address3))
    output$ba1p2 <- renderText(paste(compress$location.zipcode, " ", compress$location.city, ", ", compress$location.state, ", ", compress$location.country, sep = ""))
    
    reviews <- paste("businesses/", compress$id, "/reviews", sep = "")
    response <- GET(url = paste(base_yelp_url, reviews, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    review_data <- fromJSON(body)
    review_data$reviews$reviewer <- review_data$reviews$user$name
    output$review <- renderDataTable(DT::datatable(review_data$reviews, escape = FALSE, selection ="none"))
    
    
  })
  
  
  
  observeEvent(input$analysis_button, {
    output$analytics <- renderPlot({
      
      # This function requests business information from the YELP api
      requestData <- function(n) {
        path = "businesses/search" 
        query.params = list(term = "food", location = input$search_location, limit=50, offset=50*n-50)
        response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
        body <- content(response, "text")
        data <- fromJSON(body)
        suppressWarnings(compressed <- flatten(data[[1]]))
        return (compressed)
      }
      
      # Creates a new data frame to store Yelp business information requested from the API
      business.info <- data.frame()
      
      # This loop iterates over 20 times to obtain information from the YELP API(because YELP API only returns a maximum of 50 rows 
      # per GET request and up to a 1000 rows as a whole)
      # !! This may take a while due to the fact that 20 GET requests has to be made
      for (i in 1:20) {
        data <- requestData(i)
        business.info <- rbind(business.info, data)
      }
      
      # Creates a new data frame to store information on various categories of businesses
      business.categories <- data.frame();
      
      # This loops takes information from the "Category" column of the business dataframe(business.info) and transfers the information into a new Dataframe
      for (i in 1:nrow(business.info)) {
        data <- business.info$categories[[i]]
        business.categories <- rbind(business.categories, data)
      }
      
      # This alters the business.category dataset by grouping together similar Categories and counting the amounts of those Categories
      business.categories <- business.categories %>%
        group_by(title) %>%
        summarize(count = n())
      
      # This alters the business.category dataset by only keeping the top 6 most occuring Categories
      business.categories<- business.categories[with(business.categories,order(-count)),]
      business.categories <- business.categories[1:6,]
      
      # This plots a barplot to display the top 6 Categories for the various locations chosen.
      ggplot(business.categories, aes(x = reorder(title, -count), y = count)) + geom_bar(stat = "identity") + labs(x="Categories", y="Count") +
        ggtitle(paste0("Top 6 Categories in ", input$search_location)) + theme(plot.title = element_text(size = 30, face = "bold", hjust= 0.5 ))
    })
  })
  
}