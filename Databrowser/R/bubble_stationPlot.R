###############################################################################
# bubble_stationPlot.R
#
# Bubbles sized by overallstation usage.

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {
 
  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  source('./R/bubble_stationPlot.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='bubble_station',
                   userType='annual',
                   dayType='all',
                   timeOfDay='all',
                   distance='all')
  
  dataList <- createDataList(infoList)
  
  textList <- createTextList(dataList,infoList)
  
  bubble_stationPlot(dataList, infoList, textList)
  
}


###############################################################################

bubble_stationPlot <- function(dataList, infoList, textList) {
 
  # ----- Style ---------------------------------------------------------------
  
  # Overall
  col_text <- 'gray40'
  font <- 2
  cexFactor <- 0.5
  
  # Bad stations
  cex_station <- 1.0
  col_station <- 'white'
  font_station <- 2
  
  # Annotations
  line_title <- 3
  line_subtitle <- 1.5
  line_attribution <- 1.5
  
  
  # ----- Data Preparation ----------------------------------------------------
    
  # Get dataframe from the dataList
  trip <- dataList$trip
  station <- dataList$station
  
  # Remove 'Pronto Shop'
  station <- subset(station,terminal != 'XXX-01')

  # Create breaks
  usage <- station$dailyUsage
  breaks=quantile(usage,probs=seq(0,1,1/9))

  # Give the first three breaks meaningful small numbers but only if they are currently bigger
  if (breaks[2] > 0.5*365) {
    breaks[1:2] <- c(0,0.5)*365
  }
  
  # Set colors and sizes based on usage categories
  usageIndex <- .bincode(usage,breaks=breaks,include.lowest=TRUE)
  cols <- RColorBrewer::brewer.pal(max(usageIndex),'Spectral')[usageIndex]
  cols_border <- rep('black',length(cols))
  for (i in 1:length(cols)) cols[i] <- adjustcolor(cols[i],0.8)
  cex <- 8 * usage/max(usage)
  
  # Make the smallest circles a background for the numbers
  if (breaks[2] > 0.5*365) {
    cols[usageIndex == 1 | usageIndex == 2] <- 'red'
    cols_border[usageIndex == 1 | usageIndex == 2] <- 'red'
    cex[usageIndex == 1 | usageIndex == 2] <- 2.2 * cex_station
  }
  
  # Load background image
  ima <- png::readPNG(paste0(infoList$dataDir,"/seattlebg.png"))
  
  # Trial and error tweaks to make the stations fit properly
  centerLat=47.631
  centerLon=-122.3225
  halfHeight <- 0.036
  halfWidth <- 0.053
  xlo <- centerLon - halfWidth
  xhi <- centerLon + halfWidth
  ylo <- centerLat - halfHeight
  yhi <- centerLat + halfHeight
  
  specificUsageIndex <- .bincode(usage,breaks=365*c(0,0.5,1.5,2.5,3.5,4.5,1e9),include.lowest=TRUE)
  
  daily_0 <- specificUsageIndex <= 1
  daily_1 <- specificUsageIndex > 1 & specificUsageIndex <= 2
  daily_2 <- specificUsageIndex > 2 & specificUsageIndex <= 3
  daily_3 <- specificUsageIndex > 3 & specificUsageIndex <= 4
  daily_4 <- specificUsageIndex > 4 & specificUsageIndex <= 5
  
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
               1,
               plotHeightSum * infoList$layoutFraction_attribution)
  layout(matrix(c(3,1:2)), heights=heights)
  

  # ----- Plot ----------------------------------------------------------------

  # NOTE:  Figure inches are defined before we plot anything and should be square.
  # NOTE:  Our background image for the map is square so we need to make sure that
  # NOTE:  the sides are squeezed in a little to match the non-square plotting
  # NOTE:  region specified in the layout above.

  widthInches <- par('fin')[1]
  nonPlotFraction <- (heights[1] + heights[length(heights)]) / sum(heights)
  sideBorder <- (widthInches * nonPlotFraction) / 2

  par(mai=c(0,sideBorder,0,sideBorder))  
  
  # Blank plot to get the scaling
  xvals <- seq(xlo,xhi,length.out=5)
  yvals <- seq(ylo,yhi,length.out=5)
  
  plot(xvals, yvals, type='n', 
       axes=FALSE, xlab='', ylab='')
  
  # Get the plot information so the image will fill the plot box, and draw it
  usr <- par('usr')
  graphics::rasterImage(ima, usr[1], usr[3], usr[2], usr[4])
  
  box()

  # Draw circles
  points(station$lon,station$lat, col=cols, pch=16, cex=cex)
  points(station$lon,station$lat, col=cols_border, pch=1, cex=cex)

  if (breaks[2] > 0.5*365) {
    # Color stations with minimal usage
    text(station$lon[daily_0], station$lat[daily_0], '0', col=col_station, cex=cex_station, font=font_station)
    text(station$lon[daily_1], station$lat[daily_1], '1', col=col_station, cex=cex_station, font=font_station)
  }
  
  # Modify the passed in title
  maxValue <- max(usage,na.rm=TRUE)
  if (maxValue > 900) {
    textList$subset <- paste0(textList$subset,'  (max=',round(maxValue/365,1),'/day)')
  } else {
    textList$subset <- paste0(textList$subset,'  (max=',maxValue,'/year)')
  }

  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)


  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))
  
}
