###############################################################################
# genericPlot.R
#
# Template for plotting function scripts

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {
  
  load('data/Mazama_trip.RData')

  dataList <- list(df=trip)
  infoList <- list()
  textList <- list()
  
  
}

###############################################################################

heatmapPlot <- function(dataList, infoList, textList) {
 
  # ----- Style ---------------------------------------------------------------
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  df <- dataList$df
  
  # Convert days from 00:00-23:00 to 04:00-27:00
  # by setting all times back four hours
  startTime <- df$startTime - lubridate::dhours(3)
  timeSinceStart <- startTime - startTime[1]
  daysSinceStart <- as.integer(as.numeric(timeSinceStart,units="days"))
  weeksSinceStart <- as.integer(as.numeric(timeSinceStart,units="weeks"))
  hourOfDay <- lubridate::hour(startTime)
  dayOfWeek <- lubridate::wday(startTime)
  month <- lubridate::month(startTime)
  
  # Create factors so the table function will add zeros for missing levels
  weeksSinceStart <- factor(weeksSinceStart+1,levels=1:53)
  daysSinceStart <- factor(daysSinceStart+1,levels=1:365)
  hourOfDay <- factor(hourOfDay,levels=0:23)
  dayOfWeek <- factor(dayOfWeek,levels=1:7)
  age <- factor(age,levels=16:79)
  month <- factor(month,levels=1:12)
  
  # Create a table of # of rides
  tbl <- table(daysSinceStart,hourOfDay)
  
  ###mat <- matrix(tbl,nrow=365)
  # TODO:  have hour of day increase from top to bottom
  
  # ----- Plot ----------------------------------------------------------------
  
  image(1:365, 0:23, tbl, col=rev(heat.colors(12)),axes=FALSE,xlab='',ylab='')
  axis(2,at=seq(2,22,2),labels=paste0(seq(6,26,2),':00'),las=2)
  
  
  # ---- Annotations ----------------------------------------------------------
  
}