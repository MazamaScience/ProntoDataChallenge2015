###############################################################################
# heatmapHourByDayPlot.R
#
# Heatmap of weekly usage by hour of day.

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {
  
  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='heatmapHourByDay',
                   userType='annual',
                   gender='all',
                   age='all',
                   dayType='weekday',
                   timeOfDay='all',
                   distance='all',
                   stationId='all')
  
  dataList <- createDataList(infoList)
  
  textList <- createTextList(dataList,infoList)
  
  heatmapHourByDayPlot(dataList, infoList, textList)
  
}

###############################################################################

heatmapHourByDayPlot <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------
  
  # Overall
  col <- 'gray20'
  font <- 2
  cex <- 2
  col_box <- 'gray50'

  # Heatmap
  col_bg <- 'gray90'
  colors <- c('transparent',RColorBrewer::brewer.pal(9,'Purples'))
  lty_vert <- 1
  lwd_vert <- 2
  col_vert <- 'white'
  
  # Label positions
  monthText_ypos <- 24 # 0:23

  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  
  # Convert days from 00:00-23:00 to 04:00-27:00 by setting all times back four hours
  startTime <- trip$startTime - lubridate::dhours(3)
  timeSinceStart <- startTime - startTime[1]
  daysSinceStart <- as.integer(as.numeric(timeSinceStart,units="days"))
  weeksSinceStart <- as.integer(as.numeric(timeSinceStart,units="weeks"))
  hourOfDay <- lubridate::hour(startTime)
  month <- lubridate::month(startTime)
  
  # Create factors so the table function will add zeros for missing levels
  weeksSinceStart <- factor(weeksSinceStart+1,levels=1:53)
  daysSinceStart <- factor(daysSinceStart+1,levels=1:365)
  hourOfDay <- factor(hourOfDay,levels=0:23)
  month <- factor(month,levels=1:12)
  
  # Create a table of # of rides
  tbl <- table(trip$ProntoWeek,hourOfDay)
  
  # Convert the table (it's 1-D) into a matrix so we can rearrange the rows
  mat <- matrix(tbl,nrow=53,byrow=FALSE)
  maxValue <- max(mat, na.rm=TRUE)
  
  # Create x axes
  weeks <- seq(lubridate::ymd('2014-10-13',tz='America/Los_Angeles'),length.out=53,by='weeks')
  months <- seq(lubridate::ymd('2014-10-13',tz='America/Los_Angeles'),length.out=13,by='months')

#   # Find the first Monday of each month
#   newMonthMondays <- weeks[ which(diff(lubridate::month(weeks)) != 0) ]
  
  
  # ----- Layout --------------------------------------------------------------
  
  # NOTE:  The layoutFraction_ components are the same in every plot and guarantee
  # NOTE:  a similar look and feel across plots. The fractions are multiplied by
  # NOTE:  the sum of heights used by all other plotting rows in your plot.
  # NOTE:
  # NOTE:  For instance, if you have three plots with heights of c(2,1,1) then the
  # NOTE:  full set of plotting heights is 4 and the full set of heights will be:
  # NOTE:  heights=c(layoutFraction_title*4,2,1,1,layoutFraction_attribution*4).
  # NOTE:
  # NOTE:  The order of plotting should always start with N and end with N-1 so 
  # NOTE:  that the title is added last.
  
  # For this plot the sum of heights is 1
  plotHeightSum <- 1
  heights <- c(plotHeightSum * infoList$layoutFraction_title,
               rep(1,1),
               plotHeightSum * infoList$layoutFraction_attribution)
  layout(matrix(c(3,1:2)), heights=heights)
  
  
  # ----- Plot ----------------------------------------------------------------
  
  par(mar=c(2,4,2,4))

  # NOTE:  Plot columns (hours) in reverse order so that the time axis goes from
  # NOTE:  top to bottom.
  
#   # Background gray in case we are only plotting parts of the day
#   image(weeks[1:52], 0:23, mat[1:52,24:1]*0,
#         col=col_bg,
#         axes=FALSE, xlab='', ylab='')
  
#   # Add vertical lines at the first of each month
#   abline(v=newMonthMondays, lty=lty_vert, lwd=lwd_vert, col=col_vert)
  
  # Add the heatmap colored by data
  image(weeks[1:52], 0:23, mat[1:52,24:1],
        col=colors,
        # add=TRUE)
        axes=FALSE, xlab='', ylab='')

  box(col=col_box)
  
  # X axis
  xpos <- months[1:12]
  ypos <- monthText_ypos
  text(xpos, ypos, textList$monthLabels_3[1:12], pos=4,
       font=font, col=col, cex=cex, xpd=NA)

  # TODO:  When a time-of-day is chosen we should put a box around it and 
  # TODO:  change the labels to reflect the first and last hour of the time-of-day.
  #  Y axis
  # NOTE:  The new y axis goes, from bottom to top, from 0:23 and represents
  # NOTE:  2AM, 1AM, Midnight, 11PM, ... with 3AM at the top
  xpos <- par('usr')[1]
  ypos <- c(9,18)
  text(xpos, ypos, c('5 P','8 A'), pos=2,
       font=font, col=col, cex=cex, xpd=NA)
  
  # Modify the passed in title
  infoList$title <- paste0(textList$title,'  (max=',maxValue,')')
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))
  
}
