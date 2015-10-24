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
  textList <- list(dayLabels=c('Mon','Tue','Wed','Thu','Fri','Sat','Sun'),
                   monthLabels=c('Nov','Dec','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct'))
  
  # Testing
  heatmapPlot(dataList=list(df=subset(trip,userType=='Short-Term Pass Holder')),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,userType=='Annual Member')),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,gender=='Male')),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,gender=='Female')),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,age > 40)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,age < 30)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,elevationDiff < -50)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,elevationDiff < -100)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,elevationDiff > 50)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,elevationDiff > 100)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,stringr::str_detect(fromStationId,'CH'))),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,stringr::str_detect(fromStationId,'WF'))),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,toStationId == fromStationId)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,toStationId != fromStationId)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,distance < 500)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,distance > 500 & distance < 1500)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,distance > 1500 & distance < 2500)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,distance > 2500 & distance < 3500)),infoList,textList)
  heatmapPlot(dataList=list(df=subset(trip,distance > 3500)),infoList,textList)
  
}

###############################################################################

heatmapPlot <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------
  
  # Overall
  col_text <- 'gray40'
  font <- 2
  
  # Vertical month lines
  lty_vert <- 3
  lwd_vert <- 2
  col_vert <- 'gray50'
  
  # Heatmap
  colors <- c('transparent',RColorBrewer::brewer.pal(9,'YlOrRd'))
  
  # Labels
  label_hadj <- 0.0
  
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
  ###age <- factor(age,levels=16:79)
  month <- factor(month,levels=1:12)
  
  # Create a table of # of rides
  tbl <- table(daysSinceStart,hourOfDay)
  
  # Convert the table (it's 1-D) into a matrix
  mat <- matrix(tbl,nrow=365)
  
  # Create a date axis for x
  date <- seq(lubridate::ymd('2014-10-13',tz='America/Los_Angeles'),
              lubridate::ymd('2015-10-12',tz='America/Los_Angeles'),
              by="days")
  
  # ----- Plot ----------------------------------------------------------------
  
  image(date, 0:23, mat[,24:1],
        col=colors,
        axes=FALSE, xlab='',ylab='')
  box()
  
  # Add vertical grid lines at the first Monday of the month
  wday <- lubridate::wday(date)
  mondayIndex <- which(wday == 1)
  mondays <- date[mondayIndex]
  newMonthIndex <- which(!duplicated(lubridate::month(mondays)))[-1]
  newMonthMonday <- mondays[newMonthIndex]
  
  abline(v=newMonthMonday, lty=lty_vert, lwd=lwd_vert, col=col_vert)
  
  # X axis
  xpos <- newMonthMonday
  ypos <- label_hadj
  text(xpos, ypos, textList$monthLabels[1:11], pos=4, font=font, col=col_text)
  
  #  Y axis
  # NOTE:  The new y axis goes, from bottom to top, from 0:23 and represents
  # NOTE:  2AM, 1AM, Midnight, 11PM, ... with 3AM at the top
  locations <- c(9,18)
  labels <- c('5 PM','8 AM')
  axis(2, at=locations, labels=labels, las=1, font=font, col=col_text)
  
  
  # ---- Annotations ----------------------------------------------------------
  
  
}