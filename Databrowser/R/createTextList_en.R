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
  textList$attribution <- paste("Source:  mazamascience.com")

  textList$dayLabels=c('Mon','Tue','Wed','Thu','Fri','Sat','Sun')
  textList$monthLabels_3=c('Nov','Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct')
  textList$monthLabels_1=c('N','D','J','F','M','A','M','J','J','A','S','O')
  
  return(textList)
}
