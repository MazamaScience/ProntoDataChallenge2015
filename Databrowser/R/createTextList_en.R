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
  textList$monthLabels_3 <- c('Oct','Nov','Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct')
  textList$monthLabels_1 <- c('O','N','D','J','F','M','A','M','J','J','A','S','O')
  
  textList$temp <- "Temp"
  textList$rideCount <- "Rides"
  textList$precip <- "Rain"
  
  
  # ----- Subset info ---------------------------------------------------------

  textList$subset <- ''

  if (infoList$userType != 'all') {
    if (infoList$userType == 'annual') {
      textList$subset <- 'Annual -- '
    } else {
      textList$subset <- 'Short-Term -- '
    }
  }
  
  if (infoList$gender != 'all') {
    if (infoList$gender == 'male') {
      textList$subset <- 'men -- '   ### \u2642 is Unicode for Mars
    } else if (infoList$gender == 'women') {
      textList$subset <- 'female -- ' ### \u2640 is Unicode for Venus
    } else if (infoList$gender == 'other') {
      textList$subset <- 'other -- '
    }
  }
  
  if (infoList$age != 'all') {
    if (infoList$age == '_21') {
      textList$subset <- paste0(textList$subset,'<21 years --')
    } else if (infoList$age == '21_30') {
      textList$subset <- paste0(textList$subset,'21-30 years --')
    } else if (infoList$age == '31_40') {
      textList$subset <- paste0(textList$subset,'31-40 years --')
    } else if (infoList$age == '41_60') {
      textList$subset <- paste0(textList$subset,'41-60 years --')
    } else if (infoList$age == '61_') {
      textList$subset <- paste0(textList$subset,'>60 years --')
    }
  }

  if (infoList$dayType != 'all') {
    if (infoList$dayType == 'weekday') {
      textList$subset <- paste0(textList$subset,'weekday -- ')
    } else {
      textList$subset <- paste0(textList$subset,'weekend -- ')
    }
  }
  
  if (infoList$timeOfDay != 'all') {
    if (infoList$timeOfDay == 'amCommute') {
      textList$subset <- paste0(textList$subset,'am commute -- ')
    } else if (infoList$timeOfDay == 'midday') {
      textList$subset <- paste0(textList$subset,'mid day -- ')
    } else if (infoList$timeOfDay == 'pmCommute') {
      textList$subset <- paste0(textList$subset,'pm Commute -- ')
    } else if (infoList$timeOfDay == 'evening') {
      textList$subset <- paste0(textList$subset,'evening -- ')
    } else if (infoList$timeOfDay == 'night') {
      textList$subset <- paste0(textList$subset,'night -- ')
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
  textList$subset <- stringr::str_sub(textList$subset, start=1, end=-4)
  
  
  # ----- Title ---------------------------------------------------------------
  
  if (infoList$plotType == 'barplotDayByWeek') {
    textList$title <- 'Growth by Day'
  } else if (infoList$plotType == 'heatmapHourByDay') {
    textList$title <- 'Weekly Usage by Hour'
  } else if (infoList$plotType == 'stationBubble') {
    textList$title <- 'Station Usage'
  } else {
    textList$title <- 'TITLE GOES HERE'
  }
  
  return(textList)
}
