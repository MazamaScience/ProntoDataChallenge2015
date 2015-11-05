###############################################################################
# GENERIC_Plot.R
#
# Displays ...

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {

  
  
  
  
  source('./R/addTitleAndAttribution.R')  
  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  infoList <- list(dataDir="./data_local",
                   plotType='generic',
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

  cumulative_coasting(dataList, infoList, textList)
  
  

  
  
}


cumulative_coasting <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------

  # Overall
  font_label <- 1
  cex_label <- 5
  col_label <- 'gray20'
  
  cex_axis <- 3
  
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  trip_full <- dataList$trip_full
  station <- dataList$station
  
  tripFraction <- nrow(trip) / nrow(trip_full)

  # Calculate number of days in this subset
  JulianDay <- strftime(trip$startTime,"%Wj")
  dayCount <- length(unique(JulianDay))

  # Convert days from 00:00-23:00 to 04:00-27:00 by setting all times back four hours
  startTime <- trip$startTime - lubridate::dhours(3)

  # Create a dataframe with just "minuteOfDay" and "elevationGain" columns
  trip$minuteOfDay <- 60 * lubridate::hour(startTime) + lubridate::minute(startTime) + 1

  trip %>% select(minuteOfDay,elevationDiff) %>% 
    group_by(minuteOfDay) %>% 
    summarise(elevationGain=sum(elevationDiff)) %>% 
    arrange(minuteOfDay) -> elevationDay
  
  initialElevation <- sum( (station$elevation * station$dockCount)/2 )
  systemElevation <- initialElevation + cumsum(elevationDay$elevationGain) / dayCount / tripFraction
  systemElevation <- systemElevation / 500 # 500 bikes in system
  
  # Convert to feet
  systemElevation <- systemElevation * 3.28084
  
  
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
  
  par(mar=c(10,10,4,10))
  
  xpos <- elevationDay$minuteOfDay
  plot(xpos, systemElevation, xlim=c(1,60*24), ylim=c(-105,155), type='l',
       axes=FALSE, xlab='', ylab='',
       lwd=3, xpd=NA)
  
  # X axis
  at <- (c(6,9,12,15,18,21,24) - 4) * 60
  labels <- c('6 am','9 am','noon','3 pm','6 pm','9 pm','midnight')
  axis(1, tck=1, lty="dotted", lwd=1.5, at=at, labels=labels, las=1, mgp=c(5,1,0),
       font=font_label, cex.axis=cex_axis, col='gray70')  
  
  # Y axis
  axis(2, las=2, tck=1, lty="dotted", lwd=1.5, mgp=c(5,1,0),
       font=font_label, cex.axis=cex_axis, col='gray70')
  mtext("ft above Puget Sound", 2, line=6,
        font=font_label, cex=0.8*cex_axis, col=col_label)
  
  # Draw a "water" line
  water <- sin(0.008*pi*xpos)
  water <- -6 * abs(water) + 3
  points(xpos, water, type='l', lwd=4, col='steelblue2')
  
  
  # ----- Annotations ---------------------------------------------------------
  
  usr <- par('usr')
  
  ystart <- systemElevation[1]
  xpos <- 1
  ypos <- usr[3] + 1.02 * (usr[4] - usr[3])
  text(xpos, ypos, labels=paste0('start = ', round(ystart),' ft'), pos=4, xpd=NA,
       font=font_label, cex=cex_label, col=col_label)
  
  yend <- systemElevation[length(systemElevation)]
  xpos <- 60*24
  ypos <- yend
  text(xpos, ypos, labels= paste0(round(yend),' ft'), pos=4, xpd=NA,
       font=font_label, cex=cex_label, col=col_label)
 
  # TODO:  Need smoothing for derivative to be reliable
  
#   differences <- diff(systemElevation)
#   maxSpeed <- abs(min(differences))
#   minIndex <- which(differences==min(differences))
#   xpos <- minIndex
#   ypos <- systemElevation[minIndex]
#   points(xpos, ypos, pch=8, lwd=2, col='red', cex=4)
#   hour <- minIndex %/% 60 + 4
#   minute <- minIndex %% 60
#   label <- paste0(round(maxSpeed,2), ' ft/min at ',sprintf("%02d",hour),':',sprintf("%02d",minute))
#   text(xpos+60, ypos, label=label, pos=4,
#        font=font_label, cex=cex_label, col=col_label)
  
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  
  
#   # Bottom Line
#   xpos <- seq(1,60*27,30)
#   ypos <- rep(1.05 * min(systemElevation), length(xpos))
#   bottomLine <- loess.smooth(xpos, jitter(ypos, factor=2.0))
#   points(bottomLine, type='l', lwd=1.5, col=adjustcolor('black',0.8), xpd=NA)
#                        
#   # Left Line ()
#   xpos <- seq(1.00 * min(systemElevation), max(systemElevation), length.out=48)
#   ypos <- rep(-60,length(xpos))
#   leftLine <- loess.smooth(xpos, jitter(ypos, factor=40.0))
#   points(leftLine$y, leftLine$x, type='l', lwd=1.5, col=adjustcolor('black',0.8), xpd=NA)
#   
#   usr <- par('usr')
#   
#   # X axis noting that day starts at 04:00
#   xpos <- (c(6,9,12,15,18,21,25) - 4) * 60
#   y0 <- usr[3] - 0.05 * (usr[4] - usr[3])
#   ypos <- jitter(rep(y0,length(xpos)), factor=0.2)
#   srt <- sample(-10:10,length(xpos),replace=TRUE)
#   labels <- rep('|',length(xpos))
#   for (i in 1:length(xpos)) {
#     text(xpos[i], ypos[i], labels=labels[i], pos=3, srt=srt[i], xpd=NA)
#   }
#   srt <- sample(-2:2,length(xpos),replace=TRUE)
#   labels <- c('6 am','9 am','noon','3 pm','6 pm','9 pm','midnight')
#   for (i in 1:length(xpos)) {
#     text(xpos[i], ypos[i], labels=labels[i], pos=1, srt=srt[i], xpd=NA)
#   }
#   
# 
#   
# Plot numeric slope values at each tick mark at top of graph
#   axisIndices <- axis(1)
#   derivative <- diff(systemElevation)
#   points(diff(systemElevation*150)~elevationDay$minuteOfDay[-1], type='l', lwd=2, col='red')


  
  # ---- Cleanup and Return ---------------------------------------------------
 
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))

}


###################################
#
# IGNORE EVERYTHING BELOW HERE
#
###################################

###################################
###################################
###################################

###################################
# Install xkcd fonts

installXkcdFonts <- function() {
  
#  download.file("http://simonsoftware.se/other/xkcd.ttf", dest="xkcd.ttf", mode="wb")
#  system("mkdir ~/.fonts")
#  system("cp xkcd.ttf ~/.fonts")
  font_import(paths='~/.fonts', pattern = "[X/x]kcd", prompt=FALSE)
  fonts()
  fonttable()
  if(.Platform$OS.type != "unix") {
    ## Register fonts for Windows bitmap output
    loadfonts(device="win")
  } else {
    loadfonts()
  }
  
}




if (FALSE) {
  
  xrange <- range(mtcars$mpg)
  yrange <- range(mtcars$wt)
  set.seed(123) # for reproducibility
  p <- ggplot() + geom_point(aes(mpg, wt), data=mtcars) + xkcdaxis(xrange,yrange)
  p
  
}


