# createStationDF.R
#
# This script reads in the station data .csv file and improves it in the 
# following ways:
#
# * changes column names to adhere to MazamaScience standards
# * changes column types
# * adds additional metadata columns
#
# We will rely on the following (largely Hadley Wickham) R packages:
#
# * geosphere  - acccurate great circle distances
# * ggmap      - reverse geocoding from Google
# * httr       - easy web requests
# * lubridate  - powerful date functions
# * readr      - easy data ingest

# TODO:  come up with other metrics of proximity to:  quiet streets, transit, work and play destinations
# TODO:  get recent cencus tract level data and use MazamaScienceUtils:: to get demographic data for each station


# ----- BEGIN -----------------------------------------------------------------

# Read in, assign names and types
station <- readr::read_csv('data/2015_station_data.csv')

# > head(station,3)
# id                   name terminal      lat      long dockcount     online
#  1     3rd Ave & Broad St    BT-01 47.61842 -122.3510        18 10/13/2014
#  2      2nd Ave & Vine St    BT-03 47.61583 -122.3486        16 10/13/2014
#  3 6th Ave & Blanchard St    BT-04 47.61609 -122.3411        16 10/13/2014

# Use descriptive lowerCamelCase names
names(station) <- c('id','name','terminal','lat','lon','dockCount','onlineDate')

# Following Jake Vanderplas' lead, we'll add a station for the 'Pronto shop', giving it a unique ID
pronto_shop = list(id=1001, name="Pronto shop",
                   terminal="Pronto shop",
                   lat=47.6173156, lon=-122.3414776,
                   dockCount=100, onlineDate='10/13/2014')

station <- rbind(station,pronto_shop)

# Convert datestamp to POSIXct 
station$onlineDate <- lubridate::mdy(station$onlineDate,tz="America/Los_Angeles")

# ----- Add elevation data (meters) from Google API ---------------------------

# Create url
urlBase <- 'https://maps.googleapis.com/maps/api/elevation/json?locations='
locations <- paste(station$lat,station$lon,sep=',',collapse='|')
url <- paste0(urlBase,locations)

# Get and parse the return which has elements 'results' and 'status'
googleReturn <- httr::content(httr::GET(url))

# Check results
if (googleReturn$status != 'OK') {
  stop(paste0('Google status was "',googleReturn$status,'" for URL:\n\t',url))
}

# Convert list of lists to list of dataframes
tempList <- lapply(googleReturn$results,as.data.frame)
# Combine individual dataframes
elevationDF <- dplyr::bind_rows(tempList)

# Sanity check that things came back in the same order
if ( !all(station$lat == elevationDF$location.lat) || !all(station$lon == elevationDF$location.lon) ) {
  stop(paste0('Something is wrong with station elevation ordering.'))
}
 
station$elevation <- elevationDF$elevation
 

# ----- Add address information from Google API -------------------------------

# TODO:  add elevation and other data from Google with ggmap::revgeocode()
# NOTE:  Queries can only be done one at a time, hence the need to loop.


# ----- Add distances to other stations ---------------------------------------

# NOTE:  The geosphere::distVincentyEllipsoid distance is supposed to be very accurate.
# NOTE:  However, it is not vectorized so we use loops

# Set up empty matrix
distanceMatrix <- matrix(as.numeric(NA),nrow=nrow(station),ncol=nrow(station))
# Fill it in
for (i in 1:nrow(distanceMatrix)) {
  for (j in 1:ncol(distanceMatrix)) {
    distanceMatrix[i,j] <- geosphere::distVincentyEllipsoid(c(station$lon[i],station$lat[i]),c(station$lon[j],station$lat[j]))
  }
}

# Add column names
colnames(distanceMatrix) <- paste0('dist_',station$terminal)

# Add these columns to our station dataframe
station <- cbind(station,distanceMatrix)


# ----- Save the dataframe ----------------------------------------------------

save(station,file='data/station.RData')

readr::write_csv(station,path='data/Mazama_station.csv')

# ----- END -------------------------------------------------------------------

