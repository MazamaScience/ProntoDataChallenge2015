###############################################################################
# bubble_station.R
#
# Bubbles sized by overallstation usage.

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {
 
  
  
  
  
  source('./R/addTitleAndAttribution.R')  
  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  source('./R/bubble_station.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='bubble_stationFrom',
                   userType='all',
                   gender='female',
                   age='41_60',
                   dayType='all',
                   timeOfDay='all',
                   distance='all',
                   stationId='all',
                   layoutFraction_title=0.16,
                   layoutFraction_attribution=0.08)
  
  dataList <- createDataList(infoList)
  
  textList <- createTextList(dataList,infoList)
  
  
  
  bubble_station(dataList, infoList, textList)
  
  
  
  
  
  
}


###############################################################################

bubble_station <- function(dataList, infoList, textList) {
 
  # ----- Style ---------------------------------------------------------------
  
  # Overall
  stationMin <- 2
  stationExpansion <- 18
  

  # ----- Data Preparation ----------------------------------------------------
    
  # Get dataframe from the dataList
  trip <- dataList$trip
  station <- dataList$station
  
  # Remove 'Pronto Shop'
  station <- subset(station,terminal != 'XXX-01')

  # Create breaks
  if ( infoList$plotType == 'bubble_stationFrom' ) {
    usage <- station$dailyFromUsage
  } else if ( infoList$plotType == 'bubble_stationTo' || infoList$stationId != 'all') {
    usage <- station$dailyToUsage
  } else {
    usage <- station$dailyTotalUsage
  }
  
  # Keep track of station ordering
  stationOrdering <- order(usage)

  # Calculate breaks
  breaks=quantile(usage,probs=seq(0,1,1/9))

  # Set colors and sizes based on usage categories
  usageIndex <- .bincode(usage,breaks=breaks,include.lowest=TRUE)

  # Departures = blue-end, Arrivals = blue-end
  if ( infoList$plotType == 'bubble_stationFrom' ) {
    cols <- RColorBrewer::brewer.pal(max(usageIndex),'Reds')[usageIndex]
  } else if ( infoList$plotType == 'bubble_stationTo'  || infoList$stationId != 'all') {
    cols <- RColorBrewer::brewer.pal(max(usageIndex),'Blues')[usageIndex]
  } else {
    cols <- RColorBrewer::brewer.pal(max(usageIndex),'Purples')[usageIndex]
  }

  cols_border <- rep('black',length(cols))
  for (i in 1:length(cols)) cols[i] <- adjustcolor(cols[i],0.8)
  cex <- stationMin + stationExpansion * usage/max(usage)
  
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
  points(station$lon[stationOrdering], station$lat[stationOrdering], col=cols[stationOrdering], pch=16, cex=cex[stationOrdering])
  points(station$lon[stationOrdering], station$lat[stationOrdering], col=cols_border[stationOrdering], pch=1, cex=cex[stationOrdering])
  
  # Add a locator circle if needed
  if (infoList$stationId != 'all') {
    lon <- station$lon[station$terminal == infoList$stationId]
    lat <- station$lat[station$terminal == infoList$stationId]
    points(lon,lat, col='white', pch=16, cex=6)
    points(lon,lat, col='red', pch=16, cex=4)
    points(lon,lat, col='white', pch=16, cex=2)
  }
  
  # Modify the passed in title
  if (infoList$stationId != 'all') {
    if (infoList$plotType == 'bubble_stationTo') {
      textList$title <- paste0('Arrivals from ',infoList$stationId)
    } else if (infoList$plotType == 'bubble_stationFrom') {
      textList$title <- paste0('Departures from ',infoList$stationId)
    } else if (infoList$plotType == 'bubble_stationTotal') {
      textList$title <- paste0('Destinations from ',infoList$stationId)
    }
  }

  # Modify the passed in subtitle
  maxValue <- max(usage,na.rm=TRUE)
  if (maxValue > 900) {
    textList$subset <- paste0(textList$subset,'  (max ',round(maxValue/365,1),'/day)')
  } else {
    textList$subset <- paste0(textList$subset,'  (max ',maxValue,'/year)')
  }

  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)

  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))
  
}
