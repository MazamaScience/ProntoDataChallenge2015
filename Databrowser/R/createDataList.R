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
  
  # NOTE:  Create factors before subsetting so that all levels will be
  # NOTE:  captured. Downstream use of the table() function in plotting
  # NOTE:  scripts will insert zeros for rows or columns where a particular
  # NOTE:  is not represented in the subset dataframe.
  trip$userType <- as.factor(trip$userType)
  trip$gender <- as.factor(trip$gender)
  trip$dayOfWeek <- as.factor(trip$dayOfWeek)
  trip$hourOfDay <- as.factor(trip$hourOfDay)
  trip$age <- as.factor(trip$age)
  trip$month <- as.factor(trip$mont)
  trip$ProntoWeek <- as.factor(as.integer(trip$weeksSinceStart+1))
  trip$ProntoDay <- as.factor(as.integer(trip$daysSinceStart+1))
  
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
    } else if (infoList$userType == 'annualMale') {
      trip <- subset(trip, userType == 'Annual Member' & gender == 'Male')
    } else if (infoList$userType == 'annualFemale') {
      trip <- subset(trip, userType == 'Annual Member' & gender == 'Female')
    } else if (infoList$userType == 'annualOther') {
      trip <- subset(trip, userType == 'Annual Member' & gender == 'Other')
    } else if (infoList$userType == 'shortTerm') {
      trip <- subset(trip, userType == 'Short-Term Pass Holder')
    }

    # dayType
    # NOTE:  Need to force to integer for integer comparison.
    if (infoList$dayType == 'weekday') {
      trip <- subset(trip, as.integer(trip$dayOfWeek) <= 5)
    } else if (infoList$dayType == 'weekend') {
      trip <- subset(trip, as.integer(trip$dayOfWeek) > 5)
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

