###############################################################################
# weeklyUsageByDayOfWeekPlot.R
#
# Displays weekly usage by day of week for the selected trip subset.

if (FALSE) {

  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='weeklyUsageByDayOfWeek',
                   userType='all',
                   dayType='all',
                   timeOfDay='all',
                   distance='all')
  
  dataList <- createDataList(infoList)
  
  textList <- createTextList(dataList,infoList)

  weeklyUsageByDayOfWeekPlot(dataList, infoList, textList)
  
}

weeklyUsageByDayOfWeekPlot <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------

  # Overall
  spreadFactor <- 5
  col_text <- 'gray40'
  font <- 2
  cex <- 2
  cex_title <- 3
  cex_attribution <- 1.5
  
  # Timeseries
  lwd <- 3
  col_weekday <- 'gray70'
  col_weekend <- 'palevioletred1'
  colors <- c(rep(col_weekday,5),rep(col_weekend,2))

  # Vertical month lines
  lty_vert <- 1 # 2=dashed, 3=dotted
  lwd_vert <- 3
  col_vert <- 'white'
  
  # Labels
  hadj_day <- -0.5  # added to 0.0
  vadj_day <- 0.1   # fraction of maxScale
  
  vadj_month <- 1.2 # fraction of maxScale
  

  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip

  # Create a table of # of rides
  tbl <- table(trip$ProntoWeek,trip$dayOfWeek)
  
  # Get appropriate limits
  maxValue <- max(tbl)
  maxScale <- ifelse(maxValue > 10, maxValue, 10)
  
  # Find the location of the first Monday of each month
  date <- seq(lubridate::ymd('2014-10-13',tz='America/Los_Angeles'),
              lubridate::ymd('2015-10-12',tz='America/Los_Angeles'),
              by="weeks")
  newMonthMonday <- which(diff(lubridate::month(date)) != 0)

  # ----- Plot ----------------------------------------------------------------
  
  # NOTE:  Have the title in the top position plotted last so that the vertical
  # NOTE:  white lines with xpd=NA don't overplot the title text.
  layout(matrix(c(9,1:8)))
  
  par(mar=c(0,3,3,4))
  for (i in 1:7) {
    
    barplot(tbl[1:52,i],
            ylim=c(0, maxScale*1.05),
            axes=FALSE, xlab='', ylab='',
            names.arg=rep('',52),
            col=colors[i],border=colors[i],
            space=0)
    
    if (i == 1) {
      # Add month labels
      text(newMonthMonday[1:11], vadj_month*maxScale, textList$monthLabels_3[1:11], pos=4,
           font=font, col=col_text, cex=cex, xpd=NA)
    }
    
    # Add day label
    text(hadj_day, vadj_day*maxScale, textList$dayLabels[i], pos=2,
         font=font, col=col_text, cex=cex, xpd=NA)
    
  }
  
  # Add vertical grid lines at each new month
  abline(v=newMonthMonday, lty=lty_vert, lwd=lwd_vert, col=col_vert,xpd=NA)
  
  
  # ---- Annotations ----------------------------------------------------------

  par(mar=c(0,0,0,0))
  plot(0:1,0:1,col='transparent',axes=FALSE,xlab='',ylab='')
  text(0.5, 0.5, textList$attribution, font=1, col=col_text, cex=cex_attribution, xpd=NA)
  
  # Title and subset information at the top
  par(mar=c(0,0,0,0))
  plot(0:1,0:1,col='transparent',axes=FALSE,xlab='',ylab='')
  title <- paste0(textList$title,'  (max=',maxValue,')')
  text(0.5, 0.6, title, font=font, col=col_text, cex=cex_title, xpd=NA)
  text(0.5, 0.2, textList$subset, font=1, col=col_text, cex=cex, xpd=NA)
  
  
  # ---- Cleanup and Return ---------------------------------------------------
 
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))

}
