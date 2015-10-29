###############################################################################
# daylightPlot.R
#
# Amount of daylight.

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {
  
  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  source('./R/daylightPlot.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='daylight',
                   userType='all',
                   gender='all',
                   age='all',
                   dayType='all',
                   timeOfDay='all',
                   distance='all',
                   stationId='all',
                   layoutFraction_title=0.16,
                   layoutFraction_attribution=0.08)
  
  
  dataList <- createDataList(infoList)
  
  textList <- createTextList(dataList,infoList)
  
  daylightPlot(dataList, infoList, textList)
  
}



###############################################################################

daylightPlot <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------
  
  
  # ----- Data Preparation ----------------------------------------------------
  
  # TODO: 
  # 
  # 
  # - use par margin settings to make them bigger (try mar=c(0,0,0,0))
  # - you may have to use graphical setting xpd=NA in pie() to get the title to appear
  # - use 'M','F','O','S-T' as center text and put the counts above
  # - set colors and col_gray in the style section above

  # Get dataframe from the dataList
  trip <- dataList$trip
  
  
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
  plotHeightSum <- 2
  heights <- c(plotHeightSum * infoList$layoutFraction_title,
               1,1,
               plotHeightSum * infoList$layoutFraction_attribution)
  layout(matrix(c(6,6,1,2,3,4,5,5), nrow=4, ncol=2, byrow=TRUE), heights=heights)
  
  
  # ----- Plot ----------------------------------------------------------------
    
  # Subset by the four genders - male, female, other and non-reported(short-term users)
  maleTripDf <- subset(trip, gender=='Male')
  miniDaylightPlot(maleTripDf, title='Male Users')
  
  femaleTripDf <- subset(trip, gender=='Female')
  miniDaylightPlot(femaleTripDf, title='Female Users')
  
  otherTripDf <- subset(trip, gender=='Other')
  miniDaylightPlot(otherTripDf, title='Gender not reported')
  
  StTripDf <- subset(trip, gender=='')
  miniDaylightPlot(StTripDf, 'Short Term Users')
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))
  
}

###############################################################################

miniDaylightPlot <- function(trip, title = 'All Trips') {
  
  # Algorithm to center 'day' at top of plot'
  counts <- as.numeric(table(trip$solarPosition))
  middayFraction <- counts[[2]]/2 + counts[[1]]
  init.angle <- (middayFraction/sum(counts))*360 + 90
  
  colors <- c('#E77483', 'gold', 'orange', 'gray31')
  table <- table(trip$solarPosition)    
  
  if ( all(table==0) ) {
    
    # Gray donut with "no trips" message
    pie(1, border='gray80', col='gray80', labels=NA)
    par(new=TRUE) 
    pie(c(1), border='white', labels=NA, rad=0.4)
    text(0,0, labels= 'No\nTrips', cex=1.25, font=2)
    par(new=FALSE)
    
  } else {
    
    # Colored donut
    pie(table, border='white', labels=NA, col=colors, clockwise=T, init.angle=init.angle, main=title)
    par(new=TRUE)
    pie(c(1), border='white', labels=NA, rad=0.4)
    innerText <- as.character(nrow(trip))
    if (nchar(innerText) > 3) {
      labels <- paste0(str_sub(innerText, end=2), ',', str_sub(innerText, start=2))
      text(0,0, labels=labels, cex=1.25, font=2)    
    } else {
      text(0,0, labels=innerText, cex=1.25, font=2)  
    }
    par(new=FALSE)
    
  }
  
}


