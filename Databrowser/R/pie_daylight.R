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
                   age='21_30',
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
  
  # Overall
  font_label <- 2
  cex_label <- 4
  col_label <- infoList$col_subtitle
  
  # Ceenter of pie text
  font_center <- 2
  cex_center <- 8
  col_center <- infoList$col_subtitle
  
  # Sunset colors: day-dusk-night
  col_day <- '#F9E101'       # gold
  col_sunset1 <- '#FC7B04'   # orange
  col_sunset2 <- '#CD152D'   # red
  col_sunset3 <- '#782B48'   # red-purple
  col_sunset4 <- '#2E1E39'   # purple-black
  #sunsetPalette <- colorRampPalette(c(col_day,col_sunset1,col_sunset2,col_sunset3,col_sunset4))
  sunsetPalette <- colorRampPalette(c(col_day,col_sunset1,col_sunset3,col_sunset4))

  segmentCount <- 11
  
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  
  # Calculate percentages
  tbl <- table(trip$gender)
  sumValue <- sum(tbl)
  malePct <- round(100 * tbl['Male'] / sumValue)  
  femalePct <- round(100 * tbl['Female'] / sumValue) 
  otherPct <- round(100 * tbl['Other'] / sumValue) 
  shortTermPct <- round(100 * tbl[1] / sumValue) # NOTE:  '' is not a valid reference in a table
  
  # Subset by the four genders - male, female, other and non-reported(short-term users)
  trip_male <- subset(trip, gender=='Male')
  trip_female <- subset(trip, gender=='Female')
  trip_other <- subset(trip, gender=='Other')
  trip_shortTerm <- subset(trip, gender=='')  # All "Annual Member"s have age and gender

  
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
    
  # Removing plot area restrictions for titles
  par(xpd=NA)
  
  par(mar=c(0,6,6,0))
  centerText <- paste0(prettyNum(nrow(trip_male), big.mark=','),'\n',textList$trips)
  miniDaylightPlot(trip_male, sunsetPalette, segmentCount, centerText)
  text(0, 1.1, paste0(malePct,'% Men'), col=col_label, cex=cex_label, font=font_label, pos=3, xpd=NA)
  #   box()
  
  par(mar=c(0,0,6,6))
  centerText <- paste0(prettyNum(nrow(trip_female), big.mark=','),'\n',textList$trips)
  miniDaylightPlot(trip_female, sunsetPalette, segmentCount, centerText)
  text(0, 1.1, paste0(femalePct,'% Women'), col=col_label, cex=cex_label, font=font_label, pos=3, xpd=NA)
  #   box()
  
  par(mar=c(0,6,6,0))
  centerText <- paste0(prettyNum(nrow(trip_other), big.mark=','),'\n',textList$trips) 
  miniDaylightPlot(trip_other, sunsetPalette, segmentCount, centerText)  
  text(0, 1.1, paste0(otherPct, '% Other'), col=col_label, cex=cex_label, font=font_label, pos=3, xpd=NA)  
  #   box()
  
  par(mar=c(0,0,6,6))
  centerText <- paste0(prettyNum(nrow(trip_shortTerm), big.mark=','),'\n',textList$trips)
  miniDaylightPlot(trip_shortTerm, sunsetPalette, segmentCount, centerText)
  text(0, 1.1, paste0(shortTermPct, '% Short-Term'), col=col_label, cex=cex_label, font=font_label, pos=3, xpd=NA)    
  #   box()
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  par(xpd=FALSE)
  layout(1)
  
  
  return(c(1.0,2.0,3.0,4.0))
  
}

###############################################################################

miniDaylightPlot <- function(trip, sunsetPalette, segmentCount=21, centerText='No\nTrips', titleText='') {
  
  # Style
  font_center <- 2
  cex_center <- 4
  col_center <- 'gray20'
  
  # Algorithm to center 'day' at top of plot'
  counts <- as.numeric(table(trip$solarPosition))
  middayFraction <- counts[[2]]/2 + counts[[1]]
  init.angle <- (middayFraction/sum(counts))*360 + 90
  
  
  tbl <- table(trip$solarPosition) # dawn,day,dusk,night
  
  # Create fade-in, fade-out segments and colors
  
  dawn <- rep(tbl[1]/segmentCount,segmentCount)
  day <- tbl[2]
  dusk <- rep(tbl[3]/segmentCount,segmentCount)
  night <- tbl[4]
  fullDay <- c(dawn,day,dusk,night)
  
  sunsetColors <- sunsetPalette(segmentCount)
  fullDayColors <- c(rev(sunsetColors),sunsetColors[1],sunsetColors,sunsetColors[segmentCount])
  
  # Create the pie plots
  
  if ( all(tbl==0) ) {
    
    # Gray donut with "no trips" message
    pie(1, border='transparent', col='gray50', labels=NA, rad=1.0)
    par(new=TRUE) 
    pie(c(1), border='white', col='white', labels=NA, radius=0.5)
    centerText <- 'No\ntrips'
    text(0, 0, labels=centerText, font=font_center, cex=cex_center, col=col_center)
    par(new=FALSE)
    
  } else {
    
    # Colored donut
    pie(fullDay, border='transparent', labels=NA, col=fullDayColors, rad=1.0, clockwise=T, init.angle=init.angle)
    title(titleText)
    par(new=TRUE)
    pie(c(1), border='white', labels=NA, radius=0.5)
    text(0, 0, labels=centerText, font=font_center, cex=cex_center, col=col_center)
    par(new=FALSE)
    
  }
  
  
}


