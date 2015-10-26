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
  
  # Create factors so that table() will insert zeros
  trip$userType <- as.factor(trip$userType)
  trip$gender <- as.factor( ifelse(trip$gender == '',NA,trip$gender) )
  trip$dayOfWeek <- as.factor(trip$dayOfWeek)
  trip$hourOfDay <- as.factor(trip$hourOfDay)
  trip$age <- as.factor(trip$age)
  trip$month <- as.factor(trip$mont)
  trip$weeksSinceStart <- as.factor(as.integer(trip$weeksSinceStart+1))
  trip$daysSinceStart <- as.factor(as.integer(trip$daysSinceStart+1))
  
  # TODO:  change weeksSinceStart to weekInOperation
  # TODO:  change daysSinceStart to dayInOperation

  # Subset data
  
  if (!is.null(infoList$MazamaSubset)) {
    # Back-door for hand typed subsets
    
    # TODO:  MazamaSubset[ doesn't work yet
    trip <- subset(trip, eval(parse(text=infoList$MazamaSubset))) # No checks done so typos result in errors
    
  } else {
    # Front-door for everyone else
    
    # userType
    if (infoList$userType == 'annual') {
      trip <- subset(trip, userType == 'Annual Member')
    } else if (infoList$userType == 'shortTerm') {
      trip <- subset(trip, userType == 'Short-Term Pass Holder')
    }

    # dayType
    if (infoList$dayType == 'weekday') {
      trip <- subset(trip, dayOfWeek <= 5)
    } else if (infoList$dayType == 'weekend') {
      trip <- subset(trip, dayOfWeek > 5)
    }

    # timeOfDay
    if (infoList$timeOfDay == 'amCommute') {
      trip <- subset(trip, hourOfDay %in% 7:9)
    } else if (infoList$timeOfDay == 'midday') {
      trip <- subset(trip, hourOfDay %in% 10:15)
    } else if (infoList$timeOfDay == 'pmCommute') {
      trip <- subset(trip, hourOfDay %in% 16:18)
    } else if (infoList$timeOfDay == 'evening') {
      trip <- subset(trip, hourOfDay %in% 19:22)
    } else if (infoList$timeOfDay == 'night') {
      trip <- subset(trip, hourOfDay %in% c(0:3,21:23))
    }

    # distance
    if (infoList$distance == 'zero') {
      trip <- subset(trip, distance == 0)
    } else if (infoList$distance == '0_1') {
      trip <- subset(trip, distance < 1)
    } else if (infoList$distance == '1_2') {
      trip <- subset(trip, distance >= 1 & distance < 2)
    } else if (infoList$distance == '2_3') {
      trip <- subset(trip, distance >= 2 & distance < 3)
    } else if (infoList$distance == '3_5') {
      trip <- subset(trip, distance >= 3 & distance < 5)
    } else if (infoList$distance == '5_') {
      trip <- subset(trip, distance > 5)
    }

  }
  
  # ----- Other Data ----------------------------------------------------------
  
  station <- get(load(paste0(infoList$dataDir,'/Mazama_station.RData')))
  weather <- get(load(paste0(infoList$dataDir,'/Mazama_weather.RData')))
  
  
  # Create dataList
  dataList <- list(trip=trip,
                   station=station,
                   weather=weather)
  
  return(dataList)
  
}

