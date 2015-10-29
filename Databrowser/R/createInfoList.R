########################################################################
# createInfoList.R
#
# Create an infoList from a jsonArgs string.
#
# Besides basic conversion from strings to other data types, a lot of
# specific choices can made here that will be used later on in different
# plotting scripts.
#
# Author: Jonathan Callahan
########################################################################

createInfoList <- function(jsonArgs='{}') {

  # ----- Minumum set of infoList parameters from the UI -----------------------
  
  # Initialize the infoList from the jsonArgs
  infoList <- as.list(fromJSON(jsonArgs))
  
  # Guarantee that the following variables always have a default
  infoList$language <- ifelse(is.null(infoList$language),'en',infoList$language)
  infoList$responseType <- ifelse(is.null(infoList$responseType),'json',infoList$responseType)
  infoList$plotDevice <- ifelse(is.null(infoList$plotDevice),'png',infoList$plotDevice)
  infoList$plotWidth <- ifelse(is.null(infoList$plotWidth),640,as.numeric(infoList$plotWidth))
  infoList$plotHeight <- ifelse(is.null(infoList$plotHeight),infoList$plotWidth,as.numeric(infoList$plotHeight))

  if (is.null(infoList$plotType)) {
    stop(paste0("ERROR in createInfoList.R: required parameter plotType is missing."),call.=FALSE)
  }
  
  
  # ----- Plot styling to be used in all plots ---------------------------------
  
  # Title and attribution
  infoList$layoutFraction_title <- 0.16
  infoList$layoutFraction_attribution <- 0.08
  infoList$font_title <- 2
  infoList$col_title <- 'black'
  infoList$cex_title <- 3
  infoList$font_subtitle <- 3
  infoList$col_subtitle <- 'gray20'
  infoList$cex_subtitle <- 2.0
  infoList$font_attribution <- 1
  infoList$col_attribution <- 'gray20'
  infoList$cex_attribution <- 1.5
  
  
  # ----- Databrowser specific parameters from the UI --------------------------

  # infoList$plotType <- ifelse(is.null(infoList$plotType),'barplotDayByWeek',infoList$plotType)
  infoList$plotTypes <- ifelse(is.null(infoList$plotTypes),c('barplotDayByWeek'),strsplit(infoList$plotTypes,","))

  infoList$userType <- ifelse(is.null(infoList$userType),'all',infoList$userType)
  infoList$age <- ifelse(is.null(infoList$age),'all',infoList$age)
  infoList$gender <- ifelse(is.null(infoList$gender),'all',infoList$gender)
  infoList$dayType <- ifelse(is.null(infoList$dayType),'all',infoList$dayType)
  infoList$timeOfDay <- ifelse(is.null(infoList$timeOfDay),'all',infoList$timeOfDay)
  infoList$distance <- ifelse(is.null(infoList$distance),'all',infoList$distance)
  infoList$stationId <- ifelse(is.null(infoList$stationId),'all',infoList$stationId)

  return(infoList)
}
