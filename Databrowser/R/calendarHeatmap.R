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
  lwd_day <- 1
  col_day <- 'gray80'
  lwd_month <- 3
  col_month <- 'black'
  
  # Heatmap
  colors <- c('transparent',RColorBrewer::brewer.pal(9,'Purples'))
  
  # Labels
  label_hadj <- 24.6 # 0:23
  
  line_title <- 5.2
  line_subtitle <- 3.7
  line_attribution <- 1.9
  line_label <- 1.5
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  
  # Create factors for use in table()
  dayOfWeek <- factor(trip$dayOfWeek, levels=1:7)
  
  # Create a table of # of rides
  tbl <- table(trip$ProntoWeek,dayOfWeek)
  
  maxValue_rides <- max(tbl)
  
  # Convert to a matrix
  mat_rides <- matrix(tbl,nrow=53,byrow=FALSE)
  
  # Create daily temp and rain matrices from the weather dataframe
  missing <- rep(as.numeric(NA), 53*7 - nrow(dataList$weather))
  temp <- c(dataList$weather$Mean_Temperature_F, missing)
  mat_temp <- matrix(temp, nrow=53, byrow=TRUE)
  precip <- c(dataList$weather$Precipitation_In, missing)
  mat_precip <- matrix(precip, nrow=53, byrow=TRUE)
  
  # Max values for labeling
  maxValue_rides <- max(mat_rides, na.rm=TRUE)
  minValue_temp <- round(min(mat_temp, na.rm=TRUE))
  maxValue_temp <- round(max(mat_temp, na.rm=TRUE))
  maxValue_precip <- round(max(mat_precip, na.rm=TRUE),digits=1)
  
  
  # ----- Plot ----------------------------------------------------------------
  
  layout(matrix(c(5,seq(4))), heights=c(0.5,1,1,1,0.5))
  
  par(mar=c(1,4,1,2)+.1)  
  
  # Temp
  calendarHeatmap_sub(mat_temp[1:52,],
                      breaks=c(-1e9,seq(10,100,10),1e9),
                      col=rev(RColorBrewer::brewer.pal(11,'RdBu')))
  
  label <- print(paste0(textList$temp,':  ',minValue_temp,' - ',maxValue_temp))
  mtext(label, 2, font=font, col=col_text, cex=cex, line=line_label)
  
  # Rides
  calendarHeatmap_sub(mat_temp[1:52,])
  
  label <- print(paste0(textList$rideCount,':  0 - ',maxValue_rides))
  mtext(label, 2, font=font, col=col_text, cex=cex, line=line_label)
  
  # Precip
  calendarHeatmap_sub(mat_precip[1:52,],
                      breaks=c(-1e9,0.05,0.1,0.15,0.3,0.5,1,1.5,2,1e9),
                      col=RColorBrewer::brewer.pal(9,'Greens'))
  
  label <- print(paste0(textList$precip,':  0 - ',maxValue_precip))
  mtext(label, 2, font=font, col=col_text, cex=cex, line=line_label)
  
  
  #   # Find the location of the first Monday of each month
  #   date <- seq(lubridate::ymd('2014-10-13',tz='America/Los_Angeles'),
  #               lubridate::ymd('2015-10-12',tz='America/Los_Angeles'),
  #               by="days")
  #   newMonthMondayIndex <- which(diff(lubridate::month(date)) != 0)
  #   newMonthMonday <- date[newMonthMondayIndex]
  
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
  # ---- Annotations ----------------------------------------------------------
  
  #   # Title and subset information at the top
  #   title <- paste0(textList$title,'  (max=',maxValue_rides,')')
  #   mtext(title, side=3, line=line_title, font=font, col=col_text, cex=cex_title, xpd=NA)
  #   mtext(textList$subset, side=3, line=line_subtitle, font=1, col=col_text, cex=cex, xpd=NA)
  #   
  #   # Attribution
  #   mtext(textList$attribution, side=1, line=line_attribution, font=1, col=col_text, cex=cex_attribution, xpd=NA)
  
  # ---- Annotations ----------------------------------------------------------
  
  par(mar=c(0,0,0,0))
  plot(0:1,0:1,col='transparent',axes=FALSE,xlab='',ylab='')
  text(0.5, 0.5, textList$attribution, font=1, col=col_text, cex=cex_attribution, xpd=NA)
  
  # Title and subset information at the top
  par(mar=c(0,0,0,0))
  plot(0:1,0:1,col='transparent',axes=FALSE,xlab='',ylab='')
  title <- paste0(textList$title)
  text(0.5, 0.6, title, font=font, col=col_text, cex=cex_title, xpd=NA)
  text(0.5, 0.2, textList$subset, font=1, col=col_text, cex=cex, xpd=NA)
  
  
  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))
  
}

###############################################################################

calendarHeatmap_sub <- function(mat, date=NULL,
                                breaks=NULL,
                                col=RColorBrewer::brewer.pal(9,'Purples'),
                                lwd_day=1, col_day='gray80',
                                lwd_month=2, col_month='black') {
  
  # Inver the matrix so that Monday is at the top
  mat <- mat[,7:1]
  
  if (is.null(breaks)) {
    image(1:nrow(mat), 1:7, mat, col=col, axes=FALSE, xlab='', ylab='')    
  } else {
    image(1:nrow(mat), 1:7, mat, breaks=breaks, col=col, axes=FALSE, xlab='', ylab='')    
  }
  
  
  ###axis(2,at=1:7,labels=c('S','S','F','T','W','T','M'),las=2)
  
  # Add daily gridlines
  abline(h=0.5:7.5, col=col_day, lwd=lwd_day)
  abline(v=0.5:(nrow(mat)+0.5), col=col_day, lwd=lwd_day)
  
  # ----- Add month lines -----------------------------------------------------
  
  # Find month transitions
  if (is.null(date)) {
    date <- seq(lubridate::ymd('2014-10-13',tz='America/Los_Angeles'),
                length.out=nrow(mat)*7,
                by="days")    
  }
  monthBrick <- matrix(lubridate::month(date), nrow=nrow(mat), byrow=TRUE)
  # Reorder DayOfWeek (columns) to match Monday at top ordering in plot
  monthBrick <- monthBrick[1:nrow(mat),7:1]
  
  # Small matrix where the column # is the day of change and the cell value is the week of change
  monthChange <- apply(monthBrick, 2, function(x) { which(diff(x) != 0) })
  
  # Vertical lines
  for (i in 1:nrow(monthChange)) {
    for (j in 1:ncol(monthChange)) {
      x1 <- x2 <- monthChange[i,j] + 0.5 # Add instead of subract because diff() reduces the index by one
      y1 <- j - 0.5
      y2 <- j + 0.5
      segments(x1,y1,x2,y2, col=col_month, lwd=lwd_month)
    }
  }
  
  # Horizontal lines
  for (i in 1:nrow(monthChange)) {
    for (j in 1:ncol(monthChange)) {
      x1  <- monthChange[i,j] + 0.5 # Add instead of subract because diff() reduces the index by 
      if (j < ncol(monthChange)) {
        x2 <- monthChange[i,j+1] + 0.5
      } else {
        x2 <- x1
      }
      y1 <- y2 <- j + 0.5
      segments(x1,y1,x2,y2, col=col_month, lwd=lwd_month)      
    }
  }
  
  # Surrounding box
  abline(h=c(0.5,7.5), col=col_month, lwd=lwd_month)
  abline(v=c(0.5,(nrow(mat)+0.5)), col=col_month, lwd=lwd_month)
  
}



