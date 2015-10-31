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

  ########################################
  # Create context dependent text strings
  ########################################

  textList <- list()

  textList$attribution <- paste("data:  prontocycleshare.com        graphic:  mazamascience.com")

  textList$dayLabels_3 <- c('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
  textList$dayLabels_2 <- c('Mo','Tu','Wd','Th','Fr','Sa','Su')
  textList$dayLabels_1 <- c('M','T','W','T','F','S','S')
  # TODO:  monthLabels should start with January, not October
  textList$monthLabels_3 <- c('Oct','Nov','Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct')
  textList$monthLabels_1 <- c('O','N','D','J','F','M','A','M','J','J','A','S','O')
  
  textList$temp <- "Temp"
  textList$rideCount <- "Rides"
  textList$precip <- "Rain"
  
  textList$rides <- "rides"
  textList$trips <- "trips"
  
  textList$annual <- 'Member'
  textList$shortTerm <- 'Short-Term'
  
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
    } else if (infoList$gender == 'female') {
      textList$subset <- 'women -- ' ### \u2640 is Unicode for Venus
    } else if (infoList$gender == 'other') {
      textList$subset <- 'other -- '
    }
  }
  
  if (infoList$age != 'all') {
    if (infoList$age == '_21') {
      textList$subset <- paste0(textList$subset,'<21 year olds -- ')
    } else if (infoList$age == '21_30') {
      textList$subset <- paste0(textList$subset,'21-30 year olds -- ')
    } else if (infoList$age == '31_40') {
      textList$subset <- paste0(textList$subset,'31-40 year olds -- ')
    } else if (infoList$age == '41_60') {
      textList$subset <- paste0(textList$subset,'41-60 year olds -- ')
    } else if (infoList$age == '61_') {
      textList$subset <- paste0(textList$subset,'>60 year olds -- ')
    }
  }

  if (infoList$dayType != 'all') {
    if (infoList$dayType == 'weekday') {
      textList$subset <- paste0(textList$subset,'weekday -- ')
    } else if (infoList$dayType == 'weekend') {
      textList$subset <- paste0(textList$subset,'weekend -- ')
    } else if (infoList$dayType == 'rain__02') {
      textList$subset <- paste0(textList$subset,'<0.2 in rain -- ')
    } else if (infoList$dayType == 'rain_02') {
      textList$subset <- paste0(textList$subset,'>0.2 in rain -- ')
    } else if (infoList$dayType == 'rain_05') {
      textList$subset <- paste0(textList$subset,'>0.5 in rain -- ')
    } else if (infoList$dayType == 'rain_10') {
      textList$subset <- paste0(textList$subset,'>0.1 in rain -- ')
    } else if (infoList$dayType == 'temp__50') {
      textList$subset <- paste0(textList$subset,'<50 F -- ')
    } else if (infoList$dayType == 'temp_50') {
      textList$subset <- paste0(textList$subset,'>50 F -- ')
    } else if (infoList$dayType == 'temp_60') {
      textList$subset <- paste0(textList$subset,'>60 F -- ')
    } else if (infoList$dayType == 'temp_70') {
      textList$subset <- paste0(textList$subset,'>70 F -- ')
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
  
  
  return(textList)
}
