###############################################################################
# pie_daylight.R
#
# Amount of daylight.

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {
  
  source('./R/addTitleAndAttribution.R')
  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  source('./R/pie_daylight.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='pie_daylight',
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
  
  pie_daylight(dataList, infoList, textList)
  
  
  
  
  
  
  
  
  
  
  
  
}

# Function to turn nrow(df) into character string title


###############################################################################

pie_daylight <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------
  colors <- c('#E77483', 'gold', 'orange', 'gray31')
  
  # ----- Data Preparation ----------------------------------------------------
  
  # TODO: 
  # 
  # 
  # - use par margin settings to make them bigger (try mar=c(0,0,0,0))
  # - you may have to use graphical setting xpd=NA in pie() to get the title to appear
  # - use 'M','F','O','S-T' as center text and put the counts above
  # - set colors and col_gray in the style section above
  # - change margins to have less white space in the middle 

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
  
  # Changing margins
  par(mar=c(0,4,0,0))
  #par(oma=c(0,0,0,0))
  
  # Removing plot area restrictions for titles
  par(xpd=NA)

  # Subset by the four genders - male, female, other and non-reported(short-term users)
  par(mar=c(0,4,0,0))
  maleTripDf <- subset(trip, gender=='Male')
  miniDaylightPlot(maleTripDf, col=colors,   
                   centerText= "M")
  title(prettyNum(nrow(maleTripDf), big.mark=','), line=-3.7, cex.main=2.75)
#   box()
  
  par(mar=c(0,0,0,4))
  femaleTripDf <- subset(trip, gender=='Female')
  miniDaylightPlot(femaleTripDf, col=colors, 
                   centerText= "F")
  title(prettyNum(nrow(femaleTripDf), big.mark=','), line=-3.7, cex.main=2.75)
#   box()
  
  par(mar=c(0,4,0,0))
  otherTripDf <- subset(trip, gender=='Other')
  miniDaylightPlot(otherTripDf, col=colors, 
                   centerText= "O")
  
  title(prettyNum(nrow(otherTripDf), big.mark=','), line=-3.7, cex.main=2.75)
#   box()
  
  par(mar=c(0,0,0,4))
  StTripDf <- subset(trip, gender=='')
  miniDaylightPlot(StTripDf, col=colors,
                   centerText= "S-T")
  title(prettyNum(nrow(StTripDf), big.mark=','), line=-3.7, cex.main=2.75)
#   box()
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  #par(oma=c(2,2,2,2))
  par(xpd=FALSE)
  layout(1)
  
  
  return(c(1.0,2.0,3.0,4.0))
  
}

###############################################################################

miniDaylightPlot <- function(trip, col = 'gray80', centerText = 'No\nTrips', titleText = '') {
  
  # Algorithm to center 'day' at top of plot'
  counts <- as.numeric(table(trip$solarPosition))
  middayFraction <- counts[[2]]/2 + counts[[1]]
  init.angle <- (middayFraction/sum(counts))*360 + 90
  
  
  table <- table(trip$solarPosition)    
  
  if ( all(table==0) ) {
    
    # Gray donut with "no trips" message
    pie(1, border='gray80', labels=NA, rad=1.2)
    title('No Trips')
    par(new=TRUE) 
    pie(c(1), border='white', labels=NA, rad=0.4)
    text(0,0, labels= centerText, cex=3, font=2)
    par(new=FALSE)
    
  } else {
    
    # Colored donut
    pie(table, border='white', labels=NA, col=col, rad=1.0, clockwise=T, init.angle=init.angle)
    title(titleText)
    par(new=TRUE)
    pie(c(1), border='white', labels=NA, rad=0.4)
    text(0,0, labels=centerText, cex=3, font=2)
    par(new=FALSE)
    
  }
  
  
}


