###############################################################################
# dailyUsageByHourOfDayPlot.R
#
# Hour by day dailyUsageByHourOfDay.

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {
  
  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='calendarHeatmap',
                   userType='all',
                   dayType='all',
                   timeOfDay='all',
                   distance='all')
  
  dataList <- createDataList(infoList)
  
  textList <- createTextList(dataList,infoList)
  
  calendarHeatmapPlot(dataList, infoList, textList)
  
}

###############################################################################

calendarHeatmapPlot <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------
  
  # Overall
  col_text <- 'gray40'
  font <- 2
  cexFactor <- 0.65
  cex <- 2 * cexFactor
  cex_title <- 3 * cexFactor
  cex_attribution <- 1.5 * cexFactor
  
  # Vertical month lines
  lty_vert <- 3
  lwd_vert <- 2
  col_vert <- 'gray50'
  
  # Heatmap
  ###colors <- c('transparent',RColorBrewer::brewer.pal(9,'YlOrRd'))
  colors <- c('transparent',RColorBrewer::brewer.pal(9,'Purples'))
  
  # Labels
  label_hadj <- 24.6 # 0:23

  line_title <- 5.2
  line_subtitle <- 3.7
  line_attribution <- 1.9
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  
#   # Convert days from 00:00-23:00 to 04:00-27:00 by setting all times back four hours
#   startTime <- trip$startTime - lubridate::dhours(3)
#   timeSinceStart <- startTime - startTime[1]
#   daysSinceStart <- as.integer(as.numeric(timeSinceStart,units="days"))
#   weeksSinceStart <- as.integer(as.numeric(timeSinceStart,units="weeks"))
#   hourOfDay <- lubridate::hour(startTime)
#   month <- lubridate::month(startTime)
#   
#   # Create factors so the table function will add zeros for missing levels
#   weeksSinceStart <- factor(weeksSinceStart+1,levels=1:53)
#   daysSinceStart <- factor(daysSinceStart+1,levels=1:365)
#   hourOfDay <- factor(hourOfDay,levels=0:23)
#   month <- factor(month,levels=1:12)
  
  week <- factor(lubridate::week(trip$startTime), levels=1:53)
  dayOfWeek <- factor(trip$dayOfWeek, levels=1:7)
  
  # Create a table of # of rides
  tbl <- table(trip$ProntoWeek,dayOfWeek)
  
  mat <- matrix(tbl,nrow=53)
  
  image(1:53, 1:7, mat[,7:1], col=brewer.pal(19,'Purples'),
        axes=FALSE, xlab='',ylab='')
  axis(2,at=1:7,labels=c('S','S','F','T','W','T','M'),las=2)
  
  abline(h=0.5:7.5, col='gray80')
  abline(v=0.5:53.5, col='gray80')
  
  # Find month transitions
  date <- seq(lubridate::ymd('2014-10-13',tz='America/Los_Angeles'),
              length.out=53*7,
              by="days")
  monthBrick <- matrix(lubridate::month(date), nrow=53, byrow=TRUE)  # byrow = FALSE by default
  # Reorder DayOfWeek (columns) to match  reversed ordering in plot
  monthBrick <- monthBrick[,7:1]
  # DayOfWeek is guaranteed to have a month change
  verticalSegments <- apply(monthBrick, 2, function(x) { which(diff(x) != 0) })
  
  for (i in 1:nrow(verticalSegments)) {
    for (j in 1:ncol(verticalSegments)) {
      x1 <- x2 <- verticalSegments[i,j] + 0.5 # Add instead of subract because diff() reduces the index by one
      y1 <- j - 0.5
      y2 <- j + 0.5
      segments(x1,y1,x2,y2, lwd=2)
    }
  }
  
  # TODO:  Finish this calendar stuff
  
#   # Week of year is NOT guaranteed to have a month change
#   monthChange <- apply(monthBrick, 2, diff)
#   horizontalSegments_x <- which( apply(monthChange, 1, sd) != 0)
#   horizontalSegments_y <- which( apply(monthChange, 2, sd) != 0)
#   
#   segmentCount <- length(horizontalSegments) / 2
#   for (i in 1:segmentCount) {
#     x1 <- horizontalSegments[i*2-1] - 0.5
#     x2 <- horizontalSegments[i*2] + 0.5
#     y1 <- y2 <- verticalSegments[,i] + 0.5
#   }
#   

  
  segments(2.5,0.5,2.5,2.5,lwd=2)
  segments(2.5,2.5,3.5,2.5,lwd=2)
  segments(3.5,2.5,3.5,7.5,lwd=2)
  
  # Surrounding box
  abline(h=c(0.5,7.5),lwd=2)
  abline(v=c(0.5,53.5),lwd=2)
  
  
#   maxValue <- max(tbl)
#   
#   # Convert the table (it's 1-D) into a matrix so we can rearrange the rows
#   mat <- matrix(tbl,nrow=365)
#   
#   # Find the location of the first Monday of each month
#   date <- seq(lubridate::ymd('2014-10-13',tz='America/Los_Angeles'),
#               lubridate::ymd('2015-10-12',tz='America/Los_Angeles'),
#               by="days")
#   newMonthMondayIndex <- which(diff(lubridate::month(date)) != 0)
#   newMonthMonday <- date[newMonthMondayIndex]
  
  # ----- Plot ----------------------------------------------------------------
  
#   par(mar=c(5,3.5,8,4))
# 
#   # NOTE:  Plot columns (hour) in reverse order so that the time axis goes from
#   # NOTE:  top to bottom.
#   image(date, 0:23, mat[,24:1],
#         col=colors,
#         axes=FALSE, xlab='',ylab='')
#   box()
#   
#   # Add vertical grid lines at the first Monday of the month
#   abline(v=newMonthMonday, lty=lty_vert, lwd=lwd_vert, col=col_vert)
#   
#   # X axis
#   xpos <- newMonthMonday[1:11]
#   ypos <- label_hadj
#   text(xpos, ypos, textList$monthLabels_3[1:11], pos=4,
#        font=font, col=col_text, cex=cex, xpd=NA)
# 
#   #  Y axis
#   # NOTE:  The new y axis goes, from bottom to top, from 0:23 and represents
#   # NOTE:  2AM, 1AM, Midnight, 11PM, ... with 3AM at the top
#   xpos <- date[1]
#   ypos <- c(9,18)
#   text(xpos, ypos, c('5 pm','8 am'), pos=2,
#        font=font, col=col_text, cex=cex, xpd=NA)
#   
# 
#   # ---- Annotations ----------------------------------------------------------
#   
#   # Title and subset information at the top
#   title <- paste0(textList$title,'  (max=',maxValue,')')
#   mtext(title, side=3, line=line_title, font=font, col=col_text, cex=cex_title, xpd=NA)
#   mtext(textList$subset, side=3, line=line_subtitle, font=1, col=col_text, cex=cex, xpd=NA)
# 
#   # Attribution
#   mtext(textList$attribution, side=1, line=line_attribution, font=1, col=col_text, cex=cex_attribution, xpd=NA)
# 
#   
#   # ---- Cleanup and Return ---------------------------------------------------
#   
#   # Restore Global Graphical Parameters
#   par(mar=c(5,4,4,2)+.1)
#   layout(1)
#   
  return(c(1.0,2.0,3.0,4.0))
  
}
