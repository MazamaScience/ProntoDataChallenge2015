########################################################################
# createDataList.R
#
# Databrowser specific creation of dataframes for inclusion in dataList.
#
# Author: Jonathan Callahan
########################################################################

createDataList <- function(infoList) {
  
  # ----- Trip Data -----------------------------------------------------------
  
  # Load data
  trip <- get(load(paste0(infoList$dataDir,'/Mazama_trip.RData')))
  trip_full <- trip
  
  startingRowCount <- nrow(trip)

  # NOTE:  Create factors before subsetting so that all levels will be
  # NOTE:  captured. Downstream use of the table() function in plotting
  # NOTE:  scripts will insert zeros for rows or columns where a particular
  # NOTE:  is not represented in the subset dataframe.
  trip$userType <- as.factor(trip$userType)
  trip$gender <- as.factor(trip$gender)
  trip$dayOfWeek <- as.factor(trip$dayOfWeek)
  trip$hourOfDay <- as.factor(trip$hourOfDay)
  ###trip$age <- as.factor(trip$age) # NOTE:  Do not convert age to factor
  trip$month <- as.factor(trip$month)
  trip$ProntoWeek <- as.factor(as.integer(trip$weeksSinceStart+1))
  trip$ProntoDay <- as.factor(as.integer(trip$daysSinceStart+1))
  
  # Create an alternative dayOfWeek that starts on Monday
  dayOfWeek <- as.numeric(trip$dayOfWeek) - 1
  dayOfWeek[dayOfWeek == 0] <- 7
  trip$dayOfWeek_MondayStart <- factor(dayOfWeek, levels=1:7)
  
  
  # ----- Subset Trip ---------------------------------------------------------
  
  # userType
  if (infoList$userType == 'annual') {
    trip <- subset(trip, userType == 'Annual Member')
  } else if (infoList$userType == 'shortTerm') {
    trip <- subset(trip, userType == 'Short-Term Pass Holder')
  }
  
  # age
  if (infoList$age == '_21') {
    trip <- subset(trip, trip$userType == 'Annual Member' & trip$age < 21)
  } else if (infoList$age == '21_30') {
    trip <- subset(trip, trip$userType == 'Annual Member' & trip$age >= 21 & trip$age < 31)    
  } else if (infoList$age == '31_40') {
    trip <- subset(trip, trip$userType == 'Annual Member' & trip$age >= 31 & trip$age < 41)
  } else if (infoList$age == '41_60') {
    trip <- subset(trip, trip$userType == 'Annual Member' & trip$age >= 41 & trip$age < 61)
  } else if (infoList$age == '61_') {
    trip <- subset(trip, trip$userType == 'Annual Member' & trip$age >= 61)
  }

  # gender
  if (infoList$gender == 'male') {
    trip <- subset(trip, userType == 'Annual Member' & gender == 'Male')
  } else if (infoList$gender == 'female') {
    trip <- subset(trip, userType == 'Annual Member' & gender == 'Female')
  } else if (infoList$gender == 'other') {
    trip <- subset(trip, userType == 'Annual Member' & gender == 'Other')
  }
  
  # dayType
  # NOTE:  Need to force to integer for integer comparison.
  if (infoList$dayType == 'weekday') {
    trip <- subset(trip, trip$dayOfWeek %in% 2:6)    # lubridate weeks begin on Sunday
  } else if (infoList$dayType == 'weekend') {
    trip <- subset(trip, trip$dayOfWeek %in% c(1,7)) # lubridate weeks begin on Sunday
  } else if (infoList$dayType == 'Oct_Mar') {
    trip <- subset(trip, trip$month %in% c(10:12,1:3))
  } else if (infoList$dayType == 'Apr_Sep') {
    trip <- subset(trip, trip$month %in% c(4:9))
  } else if (infoList$dayType == 'rain__02') {
    trip <- subset(trip, trip$precipIn < 0.02)
  } else if (infoList$dayType == 'rain_02') {
    trip <- subset(trip, trip$precipIn >= 0.02)
  } else if (infoList$dayType == 'rain_05') {
    trip <- subset(trip, trip$precipIn >= 0.05)
  } else if (infoList$dayType == 'rain_10') {
    trip <- subset(trip, trip$precipIn >= 0.10)
  } else if (infoList$dayType == 'temp__50') {
    trip <- subset(trip, trip$meanTempF < 50)
  } else if (infoList$dayType == 'temp_50') {
    trip <- subset(trip, trip$meanTempF >= 50)
  } else if (infoList$dayType == 'temp_60') {
    trip <- subset(trip, trip$meanTempF >= 70)
  } else if (infoList$dayType == 'temp_70') {
    trip <- subset(trip, trip$meanTempF >= 70)
  } else if (infoList$dayType == 'APA_conference') {
    APA_startTime <- lubridate::ymd("2015-04-18",tz="America/Los_Angeles")
    APA_stopTime <- lubridate::ymd("2015-04-22",tz="America/Los_Angeles")
    trip <- subset(trip, startTime > APA_startTime & startTime < APA_stopTime)
  }
  
  # timeOfDay
  if (infoList$timeOfDay == 'early') {
    trip <- subset(trip, hourOfDay %in% 4:6)
  } else if (infoList$timeOfDay == 'amCommute') {
    trip <- subset(trip, hourOfDay %in% 7:9)
  } else if (infoList$timeOfDay == 'midday') {
    trip <- subset(trip, hourOfDay %in% 10:15)
  } else if (infoList$timeOfDay == 'pmCommute') {
    trip <- subset(trip, hourOfDay %in% 16:18)
  } else if (infoList$timeOfDay == 'evening') {
    trip <- subset(trip, hourOfDay %in% 19:22)
  } else if (infoList$timeOfDay == 'night') {
    trip <- subset(trip, hourOfDay %in% c(0:3,23))
  }
  
  # distance (in meters)
  if (infoList$distance == 'zero') {
    trip <- subset(trip, trip$distance == 0)
  } else if (infoList$distance == '0_1') {
    trip <- subset(trip, trip$distance < 1000)
  } else if (infoList$distance == '1_2') {
    trip <- subset(trip, trip$distance >= 1000 & trip$distance < 2000)
  } else if (infoList$distance == '2_3') {
    trip <- subset(trip, trip$distance >= 2000 & trip$distance < 3000)
  } else if (infoList$distance == '3_5') {
    trip <- subset(trip, trip$distance >= 3000 & trip$distance < 5000)
  } else if (infoList$distance == '5_') {
    trip <- subset(trip, trip$distance > 5000)
  }
  
  # station
  if (infoList$stationId != 'all') {
    trip <- subset(trip, trip$fromStationId == infoList$stationId)
  }
      
  endingRowCount <- nrow(trip)

  print(paste0(endingRowCount,' of ',startingRowCount,' rows retained.'))
      
    
  # ----- Station Data --------------------------------------------------------
  
  station <- get(load(paste0(infoList$dataDir,'/Mazama_station.RData')))
  
  # ----- Generate Counts Columns ---------------------------------------------
  
  trip$fromStationId <- as.factor(trip$fromStationId)
  trip$toStationId <- as.factor(trip$toStationId)
  
  # Create a table of # of rides
  fromTable <- table(trip$fromStationId)
  toTable <- table(trip$toStationId)
  
  # Add these as columns to the 'station' dataframe, ensuring proper ordering
  station$fromCount <- as.numeric(fromTable[station$terminal])
  station$fromCount[is.na(station$fromCount)] <- 0
  station$toCount <- as.numeric(toTable[station$terminal])
  station$toCount[is.na(station$toCount)] <- 0
  station$totalCount <- station$fromCount + station$toCount
  
  scaling <- station$onlineDays/max(station$onlineDays)
  
  station$dailyFromUsage <- station$fromCount * scaling
  station$dailyToUsage <- station$toCount * scaling
  station$dailyTotalUsage <- station$totalCount * scaling
  
  
  # ----- Weather Data --------------------------------------------------------
  
  weather <- get(load(paste0(infoList$dataDir,'/Mazama_weather.RData')))
  

  # ----- Finish and Return ---------------------------------------------------
  
  # Create dataList
  dataList <- list(trip=trip,
                   trip_full=trip_full,
                   station=station,
                   weather=weather)
  
  return(dataList)
  
}

