########################################################################
# textList_en.R
#
# English language text strings.
#
# Author: Jonathan Callahan
########################################################################

createTextList <- function(dataList, infoList) {

  ########################################
  # Extract data from 'dataList' object 
  ########################################

  ########################################
  # Extract variables from the 'infoList' object
  ########################################

  # Extra information
  plotType <- ifelse(is.null(infoList$plotType),'TrigFunctions',infoList$plotType)
  plotWidth <- as.numeric( ifelse(is.null(infoList$plotWidth),'500',infoList$plotWidth) )
  trigFunction <- ifelse(is.null(infoList$trigFunction),'cos',infoList$trigFunction)

  ########################################
  # Create context dependent text strings
  ########################################

  textList <- list()

  textList$title <- paste("TrigFunctions_plot --",trigFunction)
  textList$attribution <- paste("data:  ProntoCycleShare.com        graphic:  MazamaScience.com")

  textList$dayLabels <- c('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
  textList$monthLabels_3 <- c('Nov','Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct')
  textList$monthLabels_1 <- c('N','D','J','F','M','A','M','J','J','A','S','O')
  
  textList$temp <- "Temp"
  textList$rideCount <- "Rides"
  textList$precip <- "Rain"
  
  
  # ----- Subset info ---------------------------------------------------------

  textList$subset <- ''

  if (infoList$userType != 'all') {
    if (infoList$userType == 'annual') {
      textList$subset <- 'Annual -- '
    } else if (infoList$userType == 'annualMale') {
      textList$subset <- 'Annual (male) -- '
    } else if (infoList$userType == 'annualFemale') {
      textList$subset <- 'Annual (female) -- '
    } else if (infoList$userType == 'annualOther') {
      textList$subset <- 'Annual (other) -- '
    } else {
      textList$subset <- 'Short-Term -- '
    }
  }
  
  if (infoList$dayType != 'all') {
    if (infoList$dayType == 'weeday') {
      textList$subset <- paste0(textList$subset,'Weekday -- ')
    } else {
      textList$subset <- paste0(textList$subset,'Weekday -- ')
    }
  }
  
  if (infoList$timeOfDay != 'all') {
    if (infoList$timeOfDay == 'amCommute') {
      textList$subset <- paste0(textList$subset,'AM Commute -- ')
    } else if (infoList$timeOfDay == 'midday') {
      textList$subset <- paste0(textList$subset,'Mid Day -- ')
    } else if (infoList$timeOfDay == 'pmCommute') {
      textList$subset <- paste0(textList$subset,'PM Commute -- ')
    } else if (infoList$timeOfDay == 'evening') {
      textList$subset <- paste0(textList$subset,'Evening -- ')
    } else if (infoList$timeOfDay == 'night') {
      textList$subset <- paste0(textList$subset,'Night -- ')
    }
  }
  
  if (infoList$distance != 'all') {
    if (infoList$distance == 'zero') {
      textList$subset <- paste0(textList$subset,'0 km -- ')
    } else if (infoList$distance == '0_1') {
      textList$subset <- paste0(textList$subset,'<1 km -- ')
    } else if (infoList$distance == '1_2') {
      textList$subset <- paste0(textList$subset,'1-2 km -- ')
    } else if (infoList$distance == '2_3') {
      textList$subset <- paste0(textList$subset,'2-3 km -- ')
    } else if (infoList$distance == '3_5') {
      textList$subset <- paste0(textList$subset,'3-5 km -- ')
    } else if (infoList$distance == '5_') {
      textList$subset <- paste0(textList$subset,'>5 km -- ')
    }
  }
  
  # Strip off first and last ','
  textList$subset <- stringr::str_sub(textList$subset, start=1, end=-5)
  
  
  # ----- Title ---------------------------------------------------------------
  
  if (infoList$plotType == 'weeklyUsageByDayOfWeek') {
    textList$title <- 'Weekly Usage by Day'
  } else if (infoList$plotType == 'dailyUsageByHourOfDay') {
    textList$title <- 'Daily Usage by Hour'
  } else {
    textList$title <- 'TITLE GOES HERE'
  }
  
  return(textList)
}
