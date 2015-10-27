###############################################################################
# stationBubblePlot.R
#
# Bubbles sized by overallstation usage.

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {
  
  load('data/Mazama_trip.RData')

  dataList <- list(df=trip)
  infoList <- list()
  textList <- list()
  
}

###############################################################################

stationBubblePlot <- function(dataList, infoList, textList) {
 
  load('data_local/Mazama_station.RData')
  library(png)
  
  #Replace the directory and file information with your info
  ima <- readPNG("./data_local/RgoogleMaps_Seattle.png")
  centerLat=47.620
  centerLon=-122.320
  halfHeight <- 0.068
  halfWidth <- 0.100
  xlo <- centerLon - halfWidth
  xhi <- centerLon + halfWidth
  ylo <- centerLat - halfHeight
  yhi <- centerLat + halfHeight
  
  xvals <- seq(xlo,xhi,length.out=5)
  yvals <- seq(ylo,yhi,length.out=5)
  #Set up the plot area
  plot(xvals,yvals, type='n', main="Plotting Over an Image", xlab="x", ylab="y")
  
  # Get the plot information so the image will fill the plot box, and draw it
  usr <- par('usr')
  rasterImage(ima, usr[1], usr[3], usr[2], usr[4])
  
  points(station$lon, station$lat, col='red', pch=15)


  # ----- Style ---------------------------------------------------------------
  
#   # NOTE:  RgoogleMaps max size is 640
#   size <- ifelse(infoList$plotWidth > 640, 640, infoList$plotWidth)
#   
#   # ----- Data Preparation ----------------------------------------------------
#     
#   # Get dataframe from the dataList
#   trip <- dataList$trip
#   station <- dataList$station
#   
#   fromStation <- table(trip$fromStationId)
#   station$fromCount <- as.numeric(fromStation[station$terminal])
#   toStation <- table(trip$toStation)
#   station$toCount <- as.numeric(toStation[station$terminal])
#   
#   # Remove 'Pronto Shop'
#   station <- subset(station,terminal != 'XXX-01')
#   oldPar <- par()
#   par(mar=c(5,20,4,2)+.1)
#   barplot(station$fromCount, horiz=TRUE, names.arg=station$name, las=2)
#   par(oldPar)
#   
#   rawUsage <- station$fromCount + station$toCount
#   usage <- rawUsage * station$onlineDays/max(station$onlineDays)
#   
#   breaks=quantile(usage,probs=seq(0,1,1/9))
#   # Give the first three breaks meaningful numbers
#   breaks[1:3] <- c(0,1,3)*365
#   usageIndex <- .bincode(usage,breaks=breaks,include.lowest=TRUE)
#   cols <- brewer.pal(max(usageIndex),'Spectral')[usageIndex]
#   cex <- 6 * station$usage/max(usage)
#   
#   
#   # ----- Plot ----------------------------------------------------------------
# 
#   destfile <- paste0(infoList$outputDir,"/",infoList$outputFileBase,".png")
#   
#   map = GetMap(center = c(lat=47.6185, lon=-122.3282),
#                size=c(infoList$plotWidth,infoListp$plotWidth),
#                destfile=destfile,
#                zoom=8, format="png8")
  
#  PlotOnStaticMap(map, station$lat, station$lon, destfile=destfile,
#                  NEWMAP=FALSE, TrueProj=FALSE,
#                  col=cols, pch=16, cex=cex)
#  
#  PlotOnStaticMap(station$lat, station$lon, destfile=destfile,
#                  pch=1, cex=cex)
#  
  
  # ---- Annotations ----------------------------------------------------------
  
  
#   specificUsageIndex <- .bincode(usage,breaks=365*c(0,1,2,3,4,5,1e9),include.lowest=TRUE)
#   
#   daily_1 <- specificUsageIndex <= 1
#   daily_2 <- specificUsageIndex > 1 & specificUsageIndex <= 2
#   daily_3 <- specificUsageIndex > 2 & specificUsageIndex <= 3
#   # daily_4 <- specificUsageIndex > 3 & specificUsageIndex <= 4
#   # daily_5 <- specificUsageIndex > 4 & specificUsageIndex <= 5
#   
#   text(station$lon[daily_1],station$lat[daily_1],'1',col='red',cex=1.5,font=2)
#   text(station$lon[daily_2],station$lat[daily_2],'2',col='red',cex=1.5,font=2)
#   text(station$lon[daily_3],station$lat[daily_3],'3',col='red',cex=1.5,font=2)
#   # text(station$lon[daily_4],station$lat[daily_4],'4',col='red',cex=1.5,font=2)
#   # text(station$lon[daily_5],station$lat[daily_5],'5',col='red',cex=1.5,font=2)
  
  
  
  return(rep(0,4))
  
}
