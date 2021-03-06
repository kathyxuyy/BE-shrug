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

function(input, output){
  
  # this is the base yelp url for the yelp fusion API
  base_yelp_url <- "https://api.yelp.com/v3/"
  
  # This function requests business information from the YELP API and it takes it the query parameters necessary for the GET request
  getData <- function(query.params) {
    path = "businesses/search" 
    response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    data <- fromJSON(body)
    return (data)
  }
  
  ## BUSINESS SEARCH TAB
  
  # waits for the button to be clicked before executing
  observeEvent(input$search_button, {
    query.params <- list(term = input$search_input, location = input$location_input, limit = 50)
    business_data <- getData(query.params)
    
    # this line makes it so the data table can be printed without altering the values in these columns
    compress <- flatten(business_data[[1]]) %>% select(-id, -is_closed, -categories, -location.display_address, -categories, -transactions, -coordinates.latitude, -coordinates.longitude, -distance, -phone)
    compress$image_url <- paste("<img src='", compress$image_url, "' height = '60'</img>", sep = "")
    compress$url <- paste0("<a href='", compress$url, "' class = 'button'>Website</a>")
    
    # combine addresses to make clean looking address column
    compress$address <- paste0(compress$location.address1, "," , compress$location.city, ", ", compress$location.state, ", ", compress$location.zip_code, ", ", compress$location.country) 
    
    # finally, deletes the extra address columns
    compress <- select(compress,-location.address1, -location.address2, -location.city, -location.state, -location.zip_code, -location.address3, -location.country)
    
    
    # cleaning up column titles:
    colnames(compress) <- c("Name", "Image", "Yelp Link", "Review Count", "Rating", "Price", "Phone", "Address")
    
    # sends the data table to the output UI, also allows for HTML tags to apply (i.e. <a href>)
    output$businesses <- renderDataTable(DT::datatable(compress, escape = FALSE, selection = "none"))
    
  })
  
  ######################################################################################################################################################################
  
  ## LOCATION SEARCH TAB
  
  # creates a default map zoomed out to view the US 
  map <- leaflet() %>% addTiles() %>% setView(-101.204687, 40.607628, zoom = 3)
  output$myMap <- renderLeaflet(map)
  
  # preps variables that will be used later for plotting
  business_frame <- data.frame()
  center <- vector("list")
  
  # waits for the button to be pressed before getting data to be plotted
  observeEvent(input$location_button, {
    query.params = list(term = input$search_box, location = input$location_box)
    specific_data <- getData(query.params)
    
    # extracts the long, lat of the middle of the data set in question
    region <- specific_data[[3]]
    center <- region[[1]]
    
    # flattens and extracts into one data frame
    business_frame <- flatten(specific_data[[1]])
    
    # filters the resultant data based on an inputted price level
    if (input$business_filter != "") {
      business_frame <- filter(business_frame, price == input$business_filter)
    }
    
    # ensures that the map does not error out if the data frame is empty
    # if it is empty, the map will default to the long, lat of the region from the search box
    if (nrow(business_frame) == 0) {
      view_city <- geocode(input$location_box)
      output$myMap <- renderLeaflet(map %>% setView(view_city[[1]], view_city[[2]], zoom = 13))
    } else {
      output$myMap <- renderLeaflet(map %>% 
                                      setView(center[[1]],center[[2]], zoom = 13) %>% 
                                      addAwesomeMarkers(lng = business_frame$coordinates.longitude, 
                                                        lat = business_frame$coordinates.latitude, icon=icons, label = business_frame$name))
    }  
    
    # sets the color of the icons to be used  
    getColor <- function(business_frame) {
      sapply(business_frame$rating, function(rating) {
        if(rating >= 4.5) {
          "green"
        } else if(rating >= 3.5) {
          "orange"
        } else {
          "red"
        } })
    }
    
    # creates a list of icons to be used by the map
    icons <- awesomeIcons(
      icon = 'ios-close',
      iconColor = 'black',
      library = 'ion',
      markerColor = getColor(business_frame)
    )
    

  })
  
  ######################################################################################################################################################################
  
  ## BUSINESS COMPARISON TAB
  
  
  # Function will get location data based on name and location
  get_Data <- function(name, location){
    base_yelp_url <- "https://api.yelp.com/v3/"
    path = "businesses/search"
    query.params = list(term = name, location = location, limit = 1)
    response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    business_data <- fromJSON(body)
    
    compress <- flatten(business_data[[1]]) %>% select(-categories, -location.display_address, -categories, -transactions, -coordinates.latitude, -coordinates.longitude)
    compress$image_url <- paste("<img src='", compress$image_url, "' height = '250'</img>", sep = "")
    compress$url <- paste0("<a href='", compress$url, "' class = 'button'>Website</a>")
    return(compress)
  }
  
  # Function will get review data taking in a set of data
  getReviews <- function(data){
    base_yelp_url <- "https://api.yelp.com/v3/"
    reviews <- paste("businesses/", data$id, "/reviews", sep = "")
    response <- GET(url = paste(base_yelp_url, reviews, sep = ""), add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    review_data <- fromJSON(body)
    review_data$reviews$reviewer <- review_data$reviews$user$name
    review_data$reviews$url <- paste0("<a href='", review_data$reviews$url, "' class = 'button'>More</a>")
    return(review_data)
  }
  
  # Function will make star ratings
  makeStars <- function(num){
    star_rate <- ""
    for(i in 1:num){
      star_rate <- paste(star_rate, "*", sep = "")
    }
    if(num %% 1 == 0.5){
      star_rate <- paste(star_rate, ".5", sep = "")
    }
    return(star_rate)
  }
  
  # Function will get and convert a distance to miles
  getDistance <- function(num){
    dist <- round(num * 0.000621371, digits = 1)
    string <- paste(dist, "mi")
    return(string)
  }
  
  observeEvent(input$compare, {
    
    # Horizontal lines for output
    output$line <- renderText("<hr>")
    output$line2 <- renderText("<hr>")
    output$line3 <- renderText("<hr>")
    output$line4 <- renderText("<hr>")
    output$line5 <- renderText("<hr>")
    output$line6 <- renderText("<hr>")
    output$line7 <- renderText("<hr>")
    output$line8 <- renderText("<hr>")
    output$line9 <- renderText("<hr>")
    output$line10 <- renderText("<hr>")
    output$line11 <- renderText("<hr>")
    output$line12 <- renderText("<hr>")
    output$line13 <- renderText("<hr>")
    output$line14 <- renderText("<hr>")
    output$line15 <- renderText("<hr>")
    output$line16 <- renderText("<hr>")
    
    # Breaks to output
    output$break1 <- renderText("<br />")
    output$break2 <- renderText("<br />")
    output$break3 <- renderText("<br />")
    output$break4 <- renderText("<br />")
    output$break5 <- renderText("<br />")
    output$break6 <- renderText("<br />")
    output$break7 <- renderText("<br />")
    output$break8 <- renderText("<br />")
    output$break9 <- renderText("<br />")
    output$break10 <- renderText("<br />")
    output$break11 <- renderText("<br />")
    output$break12 <- renderText("<br />")
    
    # titles of sections for left side
    output$Average <- renderText("Average Rating")
    output$reviews <- renderText("Reviews")
    output$address <- renderText("Address:")
    output$price <- renderText("Price Rating:")
    output$distance <- renderText("Distance:")
    output$phone <- renderText("Phone:")
    
    # titles of sections for right side
    output$Average1 <- renderText("Average Rating")
    output$reviews1 <- renderText("Reviews")
    output$address1 <- renderText("Address:")
    output$price1 <- renderText("Price Rating:")
    output$distance1 <- renderText("Distance:")
    output$phone1 <- renderText("Phone:")
    
    # Left Side data manipulation and outputs
    compress1 <- get_Data(input$name1, input$locationlocation)
    output$bn1 <- renderText(compress1$name)
    output$bi1 <- renderText(compress1$image_url)
    output$bp1 <- renderText(paste("Phone:", compress1$display_phone))
    output$star1 <- renderText(makeStars(compress1$rating))
    output$bp1 <- renderText(compress1$display_phone)
    output$ba1p1 <- renderText(compress1$location.address1)
    output$ba1p3 <- renderText(paste(compress1$location.address2, compress1$location.address3))
    output$ba1p2 <- renderText(paste(compress1$location.zipcode, " ", compress1$location.city, ", ", compress1$location.state, ", ", compress1$location.country, sep = ""))
    output$busiPrice1 <- renderText(compress1$price)
    output$busiDist1 <- renderText(getDistance(compress1$distance))
    
    # Data get forleft  reviews
    reviews1 <- getReviews(compress1)$reviews
    
    # First Review Left Side
    if(nrow(reviews1) >= 1){
      output$reviewtext1 <- renderText(reviews1[1,]$text)
      output$more1 <- renderText(reviews1[1,]$url)
      output$reviewName1 <- renderText(reviews1[1,]$reviewer)
      output$reviewDate1 <- renderText(reviews1[1,]$time_created)
      output$reviewStars1 <- renderText(paste("Rating:", makeStars(reviews1[1,]$rating)))
    }
    
    # Second Review Left Side
    if(nrow(reviews1) >= 2){
      output$reviewtext2 <- renderText(reviews1[2,]$text)
      output$more2 <- renderText(reviews1[2,]$url)
      output$reviewName2 <- renderText(reviews1[2,]$reviewer)
      output$reviewDate2 <- renderText(reviews1[2,]$time_created)
      output$reviewStars2 <- renderText(paste("Rating:", makeStars(reviews1[2,]$rating)))
    }
    
    # Third Review Left Side
    if(nrow(reviews1) >= 3){
      output$reviewtext3 <- renderText(reviews1[3,]$text)
      output$more3 <- renderText(reviews1[3,]$url)
      output$reviewName3 <- renderText(reviews1[3,]$reviewer)
      output$reviewDate3 <- renderText(reviews1[3,]$time_created)
      output$reviewStars3 <- renderText(paste("Rating:", makeStars(reviews1[3,]$rating)))
    }
    
    
    # Right Side data manipulation and output
    compress2 <- get_Data(input$name2, input$locationlocation)
    output$bn2 <- renderText(compress2$name)
    output$bi2 <- renderText(compress2$image_url)
    output$bp2 <- renderText(paste("Phone:", compress2$display_phone))
    output$star2 <- renderText(makeStars(compress2$rating))
    output$bp2 <- renderText(compress2$display_phone)
    output$ba2p1 <- renderText(compress2$location.address1)
    output$ba2p3 <- renderText(paste(compress2$location.address2, compress2$location.address3))
    output$ba2p2 <- renderText(paste(compress2$location.zipcode, " ", compress2$location.city, ", ", compress2$location.state, ", ", compress2$location.country, sep = ""))
    output$busiPrice2 <- renderText(compress2$price)
    output$busiDist2 <- renderText(getDistance(compress2$distance))
    
    # Get reviews for right side
    reviews2 <- getReviews(compress2)$reviews
    
    # First review for right side
    if(nrow(reviews2) >= 1){
      output$reviewtext4 <- renderText(reviews2[1,]$text)
      output$more4 <- renderText(reviews2[1,]$url)
      output$reviewName4 <- renderText(reviews2[1,]$reviewer)
      output$reviewDate4 <- renderText(reviews2[1,]$time_created)
      output$reviewStars4 <- renderText(paste("Rating:", makeStars(reviews2[1,]$rating)))
    }
    
    # Second review for right side
    if(nrow(reviews2) >= 2){
      output$reviewtext5 <- renderText(reviews2[2,]$text)
      output$more5 <- renderText(reviews2[2,]$url)
      output$reviewName5 <- renderText(reviews2[2,]$reviewer)
      output$reviewDate5 <- renderText(reviews2[2,]$time_created)
      output$reviewStars5 <- renderText(paste("Rating:", makeStars(reviews2[2,]$rating)))
    }
    
    # Third review for right side
    if(nrow(reviews2) >= 3){
      output$reviewtext6 <- renderText(reviews2[3,]$text)
      output$more6 <- renderText(reviews2[3,]$url)
      output$reviewName6 <- renderText(reviews2[3,]$reviewer)
      output$reviewDate6 <- renderText(reviews2[3,]$time_created)
      output$reviewStars6 <- renderText(paste("Rating:", makeStars(reviews2[3,]$rating)))
    }
    
    
  })
  
  ######################################################################################################################################################################
  
  # This function requests business information from the YELP api and takes in parameter n for offsetting the list of returned businesses.
  requestData <- function(n, place) {
    path = "businesses/search" 
    query.params = list(term = "food", location = place, limit=50, offset=50*n-50)
    response <- GET(url = paste(base_yelp_url, path, sep = ""), query = query.params, add_headers('Authorization' = paste("bearer", yelp_api_key)), content_type_json())
    body <- content(response, "text")
    data <- fromJSON(body)
    suppressWarnings(compressed <- flatten(data[[1]]))
    return (compressed)
  }
  
  ## CATEGORIES TAB
  
  observeEvent(input$analysis_button, {
    output$analytics <- renderPlot({
      
      # Creates a new data frame to store Yelp business information requested from the API
      business.info <- data.frame()
      
      # This loop iterates over 20 times to obtain information from the YELP API(because YELP API only returns a maximum of 50 rows 
      # per GET request and up to a 1000 rows as a whole)
      # !! This may take a while due to the fact that 20 GET requests has to be made
      for (i in 1:20) {
        data <- requestData(i, input$search_location_categories)
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
        ggtitle(paste0("Most Common Categories in ", input$search_location_categories)) + theme(plot.title = element_text(size = 30, face = "bold", hjust= 0.5 ))
    })
  })
  
  ######################################################################################################################################################################
  
  ##  POPULAR RESTAURANTS 
  
  observeEvent(input$popular_button, {
    output$popular <- renderPlot({
      # Creates a new data frame to store Yelp business information requested from the API
      business.info <- data.frame()
      
      # This loop iterates over 20 times to obtain information from the YELP API(because YELP API only returns a maximum of 50 rows 
      # per GET request and up to a 1000 rows as a whole)
      # !! This may take a while due to the fact that 20 GET requests has to be made
      for (i in 1:20) {
        data <- requestData(i, input$search_location)
        business.info <- rbind(business.info, data)
      }
      
      coln <- as.numeric(input$factor)
      
      # This alters the business.info dataset keeping business with the top 7 highest no. of reviews
      business.info <- business.info[with(business.info,order(-review_count)),]
      business.info <- business.info[1:7,]
      
      # This removes all the other rows besides name, rating, price and review_count
      business.info = business.info %>%
        select(name, rating, price, review_count)
      
      # Changes the y-axis based on the input selected on the UI page
      if (coln == 2) {
        ggplot(business.info, aes(x = name, y = rating)) + geom_bar(stat = "identity") + labs(x="Most Popular restaurants", y=colnames(business.info[coln])) + 
          ggtitle(paste0("Ratings of most talked about restaurants in ",input$search_location)) + theme(plot.title = element_text(size = 20, face = "bold", hjust= 0.5)) +
          scale_x_discrete()
      } else {
        ggplot(business.info, aes(x = name, y = price)) + geom_bar(stat = "identity") + labs(x="Most Popular restaurants", y=colnames(business.info[coln])) + 
          ggtitle(paste0("Prices of most talked about restaurants in ",input$search_location)) + theme(plot.title = element_text(size = 20, face = "bold", hjust= 0.5)) +
          scale_x_discrete()
      }
    })
  })
  
}