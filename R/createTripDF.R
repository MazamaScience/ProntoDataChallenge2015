# createTripDF.R
#
# This script reads in the trip data .csv file and improves it in the 
# following ways:
#
# * changes column names to adhere to MazamaScience standards
# * changes column types
# * adds additional metadata columns
#
# We will rely on the following (largely Hadley Wickham) R packages:
#
# * dplyr      - powerful dataframe manipulations
# * geosphere  - acccurate great circle distances
# * lubridate  - powerful date functions
# * readr      - easy data ingest

# TODO:  Use maptools::sunriset() and and maptools::crepescule() to add daylight information

library(dplyr)

# ----- BEGIN -----------------------------------------------------------------

# Read in, assign names and types
trip <- readr::read_csv('./data/2015_trip_data.csv')

# > names(trip)
# [1] "trip_id"           "starttime"         "stoptime"          "bikeid"            "tripduration"     
# [6] "from_station_name" "to_station_name"   "from_station_id"   "to_station_id"     "usertype"         
# [11] "gender"            "birthyear"        

# Drop redundant columns:
# * stopTime can be calculated from startTime + duration
# * station names are found in the station dataset

trip <- dplyr::select(trip, -stoptime, -from_station_name, -to_station_name)

# > names(trip)
# [1] "trip_id"         "starttime"       "bikeid"          "tripduration"    "from_station_id"
# [6] "to_station_id"   "usertype"        "gender"          "birthyear"      


# Rename to lower camelCase
names(trip) <- c('tripId', 'startTime', 'bikeId', 'duration', 'fromStationId',
                 'toStationId', 'userType', 'gender', 'birthYear')


# ----- Convert existing columns ----------------------------------------------

# Convert dates and times to POSIXct using lubridate
trip$startTime <- lubridate::mdy_hm(trip$startTime, tz='America/Los_Angeles')

# Convert and simplify
# * integer seconds is plenty of resolution
# * all bikes start with 'SEA'
trip$duration <- as.integer(trip$duration)
trip$bikeId <- stringr::str_replace(trip$bikeId,'SEA','')

# Create factors
# NOTE:  We don't createa factors for the station IDs because we will use
# NOTE:  those as character strings to reference rows in the station dataframe.
trip$userType <- as.factor(trip$userType)
trip$gender <- as.factor(trip$gender)

# NOTE:  We added a new row to the Mazama_station dataframe:
# NOTE:  pronto_shop = list(id=1001, name="Pronto shop",
# NOTE:                     terminal="XXX-01",
# NOTE:                     lat=47.6173156, lon=-122.3414776,
# NOTE:                     dockCount=100, onlineDate='10/13/2014')
# NOTE:
# NOTE:  We need to change 'Pronto shop' to 'XXX-01' in the stationId columns
trip$fromStationId <- stringr::str_replace(trip$fromStationId,'Pronto shop','XXX-01')
trip$toStationId <- stringr::str_replace(trip$toStationId,'Pronto shop','XXX-01')


# ----- Add new columns -------------------------------------------------------

# User info
trip$age <- 2015 - trip$birthYear

# Time info
trip$timeSinceStart <- difftime(trip$startTime,trip$startTime[1])
trip$daysSinceStart <- as.integer(as.numeric(trip$timeSinceStart,units="days"))
trip$hourOfDay <- lubridate::hour(trip$startTime)
trip$dayOfWeek <- lubridate::wday(trip$startTime)
trip$month <- lubridate::month(trip$startTime)

# ----- Distance from the station dataframe -----------------------------------

load('./data/Mazama_station.RData')

# Get station-station distances from the station dataframe
# speed in units of crow-flies-meters/sec
rownames(station) <- station$terminal
distanceKey <- paste0('dist_', trip$toStationId)
trip$distance <- as.numeric(NA)
# NOTE:  Memory Death! when we try to index into the station dataframe with arrays
# NOTE:  trip$distance <- station[trip$fromStationId, trip$distanceKey] # Memory Death!
# NOTE:  Try looping instead:
for (i in 1:length(trip$distance)) {
  trip$distance[i] <- station[trip$fromStationId[i], distanceKey[i]]
  if ( (i %% 1e3) == 0 ) {
    pct <- sprintf("%3d",round(100*(i/length(trip$distance))))
    cat(paste0(pct,' %\n'))
  }
}

trip$speed <- trip$distance/trip$duration

# Elevation
# NOTE:  Access by rownames requires matrix notation
trip$elevationDiff <- station[trip$toStationId,'elevation'] - station[trip$fromStationId,'elevation']


# ----- Weather from the weather dataframe ------------------------------------

load('./data/Mazama_weather.RData')
rownames(weather) <- as.character(weather$daysSinceStart)
trip$maxTempF <- weather[as.character(trip$daysSinceStart),'Max_Temperature_F']
trip$minTempF <- weather[as.character(trip$daysSinceStart),'Max_Temperature_F']
trip$meanTempF <- weather[as.character(trip$daysSinceStart),'Mean_Temperature_F']
trip$maxHumidity <- weather[as.character(trip$daysSinceStart),'Max_Humidity_F']
trip$minHumidity <- weather[as.character(trip$daysSinceStart),'Max_Humidity_F']
trip$meanHumidity <- weather[as.character(trip$daysSinceStart),'Mean_Humidity_F']
trip$maxWindMPH <- weather[as.character(trip$daysSinceStart),'Max_Wind_Speed_MPH']
trip$meanWindMPH <- weather[as.character(trip$daysSinceStart),'Mean_Wind_Speed_MPH']
trip$precipIn <- weather[as.character(trip$daysSinceStart),'Precipitation_In']
trip$rain <- weather[as.character(trip$daysSinceStart),'rain']
trip$fog <- weather[as.character(trip$daysSinceStart),'fog']
trip$snow <- weather[as.character(trip$daysSinceStart),'snow']
trip$thunderstorm <- weather[as.character(trip$daysSinceStart),'thunderstorm']


# ----- Save the dataframe ----------------------------------------------------

# Remove the 'tbl_df' class we got from readr::read_csv
trip <- as.data.frame(trip)

save(trip, file='./data/Mazama_trip.RData')

# NOTE:  The csv file is quite large so we won't upload it to github
#readr::write_csv(trip, path='./data/Mazama_trip.csv')

# ----- END -------------------------------------------------------------------

