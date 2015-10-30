###############################################################################
# heatmap_weekByHourPlot.R
#
# Heatmap of weekly usage by hour of day.

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {
  
  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='heatmap_weekByHour',
                   userType='annual',
                   gender='all',
                   age='all',
                   dayType='weekday',
                   timeOfDay='all',
                   distance='all',
                   stationId='all',
                   layoutFraction_title=0.16,
                   layoutFraction_attribution=0.08)

  
  dataList <- createDataList(infoList)
  
  textList <- createTextList(dataList,infoList)
  
  heatmap_weekByHourPlot(dataList, infoList, textList)
  
}

###############################################################################

heatmap_weekByHourPlot <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------
  
  # Overall
  col <- 'gray20'
  font <- 2
  cex <- 2
  col_box <- 'gray50'

  # Heatmap
  colors <- c('transparent',RColorBrewer::brewer.pal(9,'Purples'))
  lty_vert <- 1
  lwd_vert <- 1.5
  col_vert <- 'black'
  
  # Label positions
  monthText_ypos <- 25 # 0:23
  hourText_xpos <- lubridate::ymd('2014-10-01',tz='America/Los_Angeles')

  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  
  # Convert days from 00:00-23:00 to 04:00-27:00 by setting all times back four hours
  startTime <- trip$startTime - lubridate::dhours(3)
  hourOfDay <- lubridate::hour(startTime)
  month <- lubridate::month(startTime)
  
  # Create factors so the table function will add zeros for missing levels
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
  
  # Find the first Monday of each month
  newMonthMondays <- weeks[ which(diff(lubridate::month(weeks)) != 0) ]
  # NOTE:  Colored blocks are centered on the 'week' so we need to scoot half a week over to 
  # NOTE:  draw verticalLines.
  # TODO:  Verify newMonthMondays
  newMonthMondays <- newMonthMondays + 7*24*60*60/2
  
  
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
  
  par(mar=c(6,6,6,3))

  # NOTE:  Plot columns (hours) in reverse order so that the time axis goes from
  # NOTE:  top to bottom.
  
  # Add the heatmap colored by data
  image(weeks[1:52], 0:23, mat[1:52,24:1],
        col=colors,
        # add=TRUE)
        axes=FALSE, xlab='', ylab='')

  # Add vertical lines at the first of each month
  abline(v=newMonthMondays, lty=lty_vert, lwd=lwd_vert, col=col_vert)
  
  box(col=col_box)
  
  # X axis
  xpos <- months[1:12] + 7*24*60*60/2 # TODO:  verify month label placement
  ypos <- monthText_ypos
  text(xpos, ypos, textList$monthLabels_3[1:12],
       font=font, col=col, cex=cex, xpd=NA)

  # TODO:  When a time-of-day is chosen we should put a box around it and 
  # TODO:  change the labels to reflect the first and last hour of the time-of-day.
  
  #  Y axis
  # NOTE:  The new y axis goes, from bottom to top, from 0:23 and represents
  # NOTE:  2AM, 1AM, Midnight, 11PM, ... with 3AM at the top
  
  if (infoList$timeOfDay == 'early') {
    times <- c(4,6); ypos <- rev(abs(times-26)); labels <- rev(c('4 am','6 am'))
  } else if (infoList$timeOfDay == 'amCommute') {
    times <- c(7,9); ypos <- rev(abs(times-26)); labels <- rev(c('7 am','9 am'))
  } else if (infoList$timeOfDay == 'midday') {
    times <- c(10,15); ypos <- rev(abs(times-26)); labels <- rev(c('10 am','3 pm'))
  } else if (infoList$timeOfDay == 'pmCommute') {
    times <- c(16,18); ypos <- rev(abs(times-26)); labels <- rev(c('4 pm','6 pm'))
  } else if (infoList$timeOfDay == 'evening') {
    times <- c(19,22); ypos <- rev(abs(times-26)); labels <- rev(c('7 pm','10 pm'))
  } else if (infoList$timeOfDay == 'night') {
    times <- c(23,3); ypos <- rev(abs(times-26)); labels <- rev(c('11 pm','3 am'))
  } else {
    times <- c(8,17); ypos <- rev(abs(times-26)); labels <- rev(c('8 am','5 pm'))
  }
  
  text(hourText_xpos, ypos, labels, pos=2, font=font, col=col, cex=cex, xpd=NA)
  
  # Modify the subset string
  textList$subset <- paste0(textList$subset,'  (max=',maxValue,')')
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))
  
}
