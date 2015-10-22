# Exploring Pronto Data
library(readr)
library(lubridate)



station <- read_csv("/Users/rubyfore/Projects/ProntoDataChallenge2015/data/2015_station_data.csv")

tripData <- read_csv('/Users/rubyfore/Projects/ProntoDataChallenge2015/data/2015_trip_data.csv')

tripData$starttime <- mdy_hm(tripData$starttime, tz="America/Los_Angeles")
tripData


# need to create a new dataset of 365 rows with 4 columns (night, dawn, day, dusk) with POSIXct times as values
# Would it be better to create a 365*4 row dataset with two columns, time and timeOfDay? YES
# We will use this data set to create a factor in tripDF that is night/dawn/day/dusk


# Alternative way: create new column or 4 that is time of day for each of these events for each trip
# Create SpatialPoints-class object to use in maptools::sunriset
seattle <- matrix(c(-122.3331, 47.6097), nrow=1)
Seattle <- SpatialPoints(seattle, proj4strin=CRS('+proj=longlat +datum=WGS84'))

trip$sunrise <- sunriset(Seattle, trip$startTime, direction='sunrise', POSIXct.out=TRUE)[1,2]


if {
  trip$startTime[[i]] >