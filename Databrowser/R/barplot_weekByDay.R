###############################################################################
# barplot_weekByDay.R
#
# Displays weekly usage by day of week for the selected trip subset.

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {

  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='barplot_weekByDay',
                   userType='all',
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

  barplot_weekByDay(dataList, infoList, textList)
  
}

barplot_weekByDay <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------

  # Overall
  col_text <- 'gray40'
  font <- 2
  cex <- 2
  
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
  plotHeightSum <- 7
  heights <- c(plotHeightSum * infoList$layoutFraction_title,
               rep(1,7),
               plotHeightSum * infoList$layoutFraction_attribution)
  layout(matrix(c(9,1:8)), heights=heights)
  

  # ----- Plot ----------------------------------------------------------------
  
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
  
  # Modify the passed in title
  textList$subset <- paste0(textList$subset,'  (max=',maxValue,'/day)')

  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  # ---- Cleanup and Return ---------------------------------------------------
 
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))

}
