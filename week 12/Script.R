

#To install Leaflet package, run this command at your R prompt:
#install.packages("leaflet")
#install.packages("htmlwidget")

# Activate the library
library(leaflet)
library(htmlwidgets) # not essential, only needed for saving the map as .html
library(tidyverse)
library(googlesheets4)
library(leaflet)
library(dplyr)




# Task 1: Create a Danish equivalent of AUSmap with Esri layers, 
# but call it DANmap. You will need it layer as a background for Danish data points.

#We found the location of Denmark
leaflet() %>% 
  setView(12, 55, zoom = 6) %>%
  addTiles()

#We assign the location of Denmark to an object
l_dan <- leaflet() %>%   
  setView(12, 55, zoom = 6)

#We prepare to select backgrounds by grabbing their names
esri <- grep("^Esri", providers, value = TRUE)

#We take the backgrounds and connect them to a object 
for (provider in esri) {
  l_dan <- l_dan %>% addProviderTiles(provider, group = provider)
}

#We make a layered map out of the components above and 
#write it to an object called DANmap 
DANmap <- l_dan %>%
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = FALSE)) %>%
  addMiniMap(tiles = esri[[1]], toggleDisplay = TRUE,
             position = "bottomright") %>%
  addMeasure(
    position = "bottomleft",
    primaryLengthUnit = "meters",
    primaryAreaUnit = "sqmeters",
    activeColor = "#3D535D",
    completedColor = "#7D4479") %>% 
  htmlwidgets::onRender("
                        function(el, x) {
                        var myMap = this;
                        myMap.on('baselayerchange',
                        function (e) {
                        myMap.minimap.changeLayer(L.tileLayer.provider(e.name));
                        })
                        }") %>% 
  addControl("", position = "topright")

#To view our map of Denmark 
DANmap

#We save a html file of the map
saveWidget(DANmap, "DANmap.html", selfcontained = TRUE)




# Task 2: Read in the googlesheet data you and your colleagues created
# into your DANmap object (with 11 background layers you created in Task 1).

#We run this line, so we dont have to sign in with your mail
gs4_deauth()

#We load in our Google sheet that we have edited 
places <- read_sheet("https://docs.google.com/spreadsheets/d/1ZzvsnbNEhzREh95O7JMgmTqbShU2ovztIsiykCmI8II/edit?gid=148633452#gid=148633452",
                     col_types = "cccnncnc",   # check that you have the right number and type of columns
                     range = "DAM2025")  # select the correct worksheet name

#We see if R reads our data correct
glimpse(places)

#We place our locations onto our map of Denmark
leaflet() %>% 
  addTiles() %>% 
  addMarkers(lng = places$Longitude, 
             lat = places$Latitude,
             popup = paste(places$Description, "<br>", places$Type)) %>% 
  addLayersControl(baseGroups = names(esri),
                   options = layersControlOptions(collapsed = FALSE))

  




# Task 3: Can you cluster the points in Leaflet?
# Hint: Google "clustering options in Leaflet in R"

#Yes, we can, if we do the following:

#We cluster three locations together
popup <- c("Århus Domkirke", "ARoS Aarhus Kunstmuseum", "Latinerkvarteret")

# We make a leaflet map with the cluster 
leaflet() %>%
  addProviderTiles("Esri.WorldPhysical") %>%
  addAwesomeMarkers(
    lng = c(10.2107, 10.1979, 10.2084),  
    lat = c(56.1567, 56.1531, 56.1573), 
    popup = popup
  )






# Task 4: Look at the two maps (with and without clustering) and consider what
# each is good for and what not.

#by using the cluster function it is possible to show a map with a lot of 
#points with a more clear view of the map. However if it is necessary to look at 
#specific datapoints it makes more sense to have all points included in the map, 
#without clustering.





# Task 5: Find out how to display the notes and classifications column in the map. 
# Hint: Check online help in sites such as 
# https://r-charts.com/spatial/interactive-maps-leaflet/#popup

#We take the three locations from task 3 and make a new object
circles <- data.frame(
  lng = c(10.2107, 10.1979, 10.2084),  
  lat = c(56.1567, 56.1531, 56.1573)  
)

#We make a new map with circles and markers
leaflet() %>%
  addTiles() %>%
  setView(lng = 10.2107, lat = 56.1567, zoom = 15) %>%  
  addCircles(data = circles, radius = 5,
             popup = paste0("<b>Århus Domkirke</b><br>Note: Kirken fra 1200-tallet",
                            "<br><b>Classification:</b> Historic")) %>%
  addCircleMarkers(data = circles,
                   popup = c("<b>ARoS Aarhus Kunstmuseum</b><br>Note: Moderne kunstmuseum<br><b>Classification:</b> Museum",
                             "<b>Latinerkvarteret</b><br>Note: Historisk bydel<br><b>Classification:</b> Cultural Area",
                             "<b>Aarhus Domkirke</b><br>Note: Kirke <cbr><b>Classification:</b>Domkirke"))


 


