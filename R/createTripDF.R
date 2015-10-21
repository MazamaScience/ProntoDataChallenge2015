

# ----- BEGIN -----------------------------------------------------------------

# Read in, assign names and types
tripData <- readr::read_csv('./data/2015_trip_data.csv')

#names(tripData)
#[1] "tripData_id"           "starttime"         "stoptime"          "bikeid"            "tripDataduration"      "from_station_name"
#[7] "to_station_name"   "from_station_id"   "to_station_id"     "usertype"          "gender"            "birthyear"  

# Rename to lower camelCase
# TODO: fix toStationId vs fromStationId
names(tripData) <- c('tripId', 'startTime', 'stopTime', 'bikeId', 'tripDuration', 'fromStationName', 
                     'toStationName', 'fromStationId', 'toStationId', 'userType', 'gender', 'birthYear')

# Convert dates and times to POSIXct using lubridate
# TODO: add weekend/weekday using lubridate or other 

tripData$startTime <- lubridate::mdy_hm(tripData$startTime, tz='America/Los_Angeles')
tripData$stopTime <- lubridate::mdy_hm(tripData$stopTime, tz ='America/Los_Angeles')

# Add more columns 

tripData$tripDuration <- as.integer(tripData$tripDuration)
tripData$age <- 2015 - tripData$birthYear
tripData$bikeId <- stringr::str_replace(tripData$bikeId,'SEA','')

# Create factors

tripData$fromStationName <- as.factor(tripData$fromStationName)
tripData$toStationName <- as.factor(tripData$toStationName)
tripData$userType <- as.factor(tripData$userType)
tripData$gender <- as.factor(tripData$gender)

# New columns

tripData$hourOfDay <- lubridate::hour(tripData$startTime)
tripData$dayOfWeek <- lubridate::wday(tripData$startTime)
tripData$weekday <- tripData$dayOfWeek <= 5
tripData$weekend <- tripData$dayOfWeek > 5
tripData$timeSinceStart <- difftime(tripData$startTime,tripData$startTime[1])
tripData$daysInOperation <- as.numeric(tripData$timeSinceStart,units="days")
tripData$tripDurationMin <- tripData$tripDuration/60

# Trip distance column 
#create a vector to of unique station combinations to reference to station dataset
#use reshape to create a long form of distances 
# Trip speed column - need tripDuration/tripDistance

rownames(station) <- station$terminal
tripData$distanceKey <- paste0('dist_', tripData$toStationId)
tripData$distance <- station[tripData$fromStationId, tripData$distanceKey]
tripData$speed <- tripData$distance/tripData$tripDurationMin

# Masks
tripData$femaleMask <- tripData$gender == 'Female'
tripData$maleMask <- tripData$gender == 'Male'
tripData$otherMask <- tripData$gender == 'Other'
tripData$over60 <- tripData$age >= 60

# ----- Save the dataframe ----------------------------------------------------

save(tripData, file='./data/Mazama_tripData.RData')

readr::write_csv(tripData, path='./data/Mazama_tripData.csv')
