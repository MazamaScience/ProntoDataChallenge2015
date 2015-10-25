########################################################################
# createDataList.R
#
# Databrowser specific creation of dataframes for inclusion in dataList.
#
# Author: Jonathan Callahan
########################################################################

createDataList <- function(infoList) {
  
  # Load data
  df <- get(load(paste0(infoList$dataDir,'/Mazama_trip.RData')))
  
  # Create factors so that table() will insert zeros
  df$userType <- as.factor(df$userType)
  df$gender <- as.factor( ifelse(df$gender == '',NA,df$gender) )
  df$dayOfWeek <- as.factor(df$dayOfWeek)
  df$hourOfDay <- as.factor(df$hourOfDay)
  df$age <- as.factor(df$age)
  df$month <- as.factor(df$mont)
  df$weeksSinceStart <- as.factor(as.integer(df$weeksSinceStart+1))
  df$daysSinceStart <- as.factor(as.integer(df$daysSinceStart+1))
  
  # TODO:  change weeksSinceStart to weekInOperation
  # TODO:  change daysSinceStart to dayInOperation

  # Subset data
  
  if (!is.null(infoList$MazamaSubset)) {
    # Back-door for hand typed subsets
    
    # TODO:  MazamaSubset[ doesn't work yet
    df <- subset(df, eval(parse(text=infoList$MazamaSubset))) # No checks done so typos result in errors
    
  } else {
    # Front-door for everyone else
    
    # userType
    if (infoList$userType == 'annual') {
      df <- subset(df, userType == 'Annual Member')
    } else if (infoList$userType == 'shortTerm') {
      df <- subset(df, userType == 'Short-Term Pass Holder')
    }

    # dayType
    if (infoList$dayType == 'weekday') {
      df <- subset(df, dayOfWeek <= 5)
    } else if (infoList$dayType == 'weekend') {
      df <- subset(df, dayOfWeek > 5)
    }

    # timeOfDay
    if (infoList$timeOfDay == 'amCommute') {
      df <- subset(df, hourOfDay %in% 6:8)
    } else if (infoList$timeOfDay == 'midday') {
      df <- subset(df, hourOfDay %in% 10:15)
    } else if (infoList$timeOfDay == 'pmCommute') {
      df <- subset(df, hourOfDay %in% 16:18)
    } else if (infoList$timeOfDay == 'evening') {
      df <- subset(df, hourOfDay %in% 19:22)
    } else if (infoList$timeOfDay == 'night') {
      df <- subset(df, hourOfDay %in% c(0:3,21:23))
    }

    # distance
    if (infoList$distance == 'zero') {
      df <- subset(df, distance == 0)
    } else if (infoList$distance == '0_1') {
      df <- subset(df, distance < 1)
    } else if (infoList$distance == '1_2') {
      df <- subset(df, distance >= 1 & distance < 2)
    } else if (infoList$distance == '2_3') {
      df <- subset(df, distance >= 2 & distance < 3)
    } else if (infoList$distance == '3_5') {
      df <- subset(df, distance >= 3 & distance < 5)
    } else if (infoList$distance == '5_') {
      df <- subset(df, distance > 5)
    }


  }
  
  # Create dataList
  dataList <- list(df=df)
  
  return(dataList)
  
}

