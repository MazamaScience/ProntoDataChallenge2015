###############################################################################
# scatter_percent_downhill.R
#
# Displays ...

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {

  
  
  
  
  
  source('./R/addTitleAndAttribution.R')  
  source('./R/createDataList.R')
  source('./R/createTextList_en.R')
  
  infoList <- list(dataDir="data_local",
                   plotType='pctDownhillScatter',
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
  
  scatter_percent_downhill(dataList, infoList, textList)
  
  
  
  
  
  
}

scatter_percent_downhill <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------

  # Overall
  font_goodStation <- 4
  cex_goodStation <- 4
  col_goodStation <- infoList$col_subtitle
  
  font_badStation <- 3
  cex_badStation <- 4
  col_badStation <- infoList$col_subtitle
  
  lwd_axis <- 2
  cex_axis <- 2.5
  cex_legend <- 3
  
  cex_xlab <- 2.5
  line_xlab <- 7
  
  # Number of bars at top/bottom
  fewCount <- 6

  # Bars
  barOpacity <- 0.6
  

  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframes from the dataList
  trip <- dataList$trip
  station <- dataList$station
  
  # Remove 'Pronto Shop'
  station <- subset(station, terminal != 'XXX-01')
  trip <- subset(trip, fromStationId != 'XXX-01' & toStationId != 'XXX-01')
  
  # Add stationPairs
  trip$fromStationId <- as.character(trip$fromStationId)
  trip$toStationId <- as.character(trip$toStationId)
  trip$stationPair <- ""
  # TODO:  Figure out some better way to generate station pairs
  cm <- as.matrix(trip[,c('fromStationId','toStationId')])
  trip$stationPair <- apply(cm, 1, function(x) paste0(sort(x),collapse='_'))

  # Add grade
  trip$grade <- ifelse(trip$distance == 0, 0, 100* trip$elevationDiff / trip$distance)
  trip$absGrade <- abs(trip$grade)
  
  # Create dataframe of station pairs
  trip_preference <- trip %>% select(absGrade,stationPair) %>% group_by(stationPair) %>% summarize(absGrade=mean(absGrade), count=n())
  
  # Create downhill-flat-uphill dataframes by station pair
  trip_downhill <- trip %>% filter(trip$grade <= -0.01) %>% group_by(stationPair) %>% summarize(downhillCount=n())
  trip_uphill <- trip %>% filter(trip$grade >= 0.01) %>% group_by(stationPair) %>% summarize(uphillCount=n())
  trip_flat <- trip %>% filter(trip$grade > -0.01 & trip$grade < 0.01) %>% group_by(stationPair) %>% summarize(flatCount=n())
  
  # Join all dataframes
  trip_preference <- left_join(trip_preference,trip_downhill,by='stationPair')
  trip_preference <- left_join(trip_preference,trip_flat,by='stationPair')
  trip_preference <- left_join(trip_preference,trip_uphill,by='stationPair')
  trip_preference[is.na(trip_preference)] <- 0
  
  # Add count and pct_downhill column
  trip_preference <- mutate(trip_preference, pctUphill = 100*uphillCount / count)  
  
  # Order the dataframe by grade
  trip_preference <- trip_preference[order(trip_preference$absGrade), ]
  

  # Call flat trips 50/50
  df <- trip_preference
  df$pctUphill[df$flatCount !=0] <- 50
  
  # Plotting
  plot(df$pctUphill ~ df$absGrade, cex=10*df$count/max(df$count), xlab='Grade in %', ylab='Percentage of trips uphill for station pairs', col='transparent')
  usr <- par('usr')
  rect(usr[1], 45, usr[2], 55, col=adjustcolor('firebrick',0.1), border=FALSE)
  abline(h=50, col=adjustcolor('firebrick',0.5), lwd=2)
  points(df$pctUphill ~ df$absGrade, cex=10*df$count/max(df$count), xlab='', ylab='', col=adjustcolor('black',0.5), pch=16)
  

  # Where do people ride uphill? 
  weeklyUphillMask <- which(df$absGrade > 5 & df$uphillCount >= 52)
  df(weeklyUphillMask)
  

  

  
  
  
    
  
#   
#   # Remove everything after the "/" from the station name
#   station$name <- stringr::str_replace(station$name,' \\/.*$','')
#   
#   # NOTE:  When we're looking at departure from a particular station only show arrivals.
#   if (infoList$stationId == 'all') {
#     usage <- station$dailyTotalUsage
#   } else {
#     usage <- station$dailyToUsage
#   }
#   indices <- order(usage, decreasing=FALSE)
#   station <- station[indices,c('name','terminal','dailyToUsage','dailyFromUsage','dailyTotalUsage')]
# 
#   # TODO:  The below is a mess but we need y_firstFew, y_middleOne and y_lastFew
#   y_firstFew <- 1:fewCount
#   y_middleOne <- fewCount + 1
#   y_lastFew <- y_middleOne:(2*fewCount+1)
#   
#   ####
#   ####
#   ####
#   
#   y_firstFew <- 1:15
#   y_middleOne <- 16
#   y_lastFew <- nrow(station)
#   
#   
#   # Top few and bottom few wit a gap in the middle
#   if (infoList$stationId == 'all') {
#     
#     
# #     firstFew <- 1:fewCount
# #     middleOne <- max(firstFew) + 1
# #     lastFew <- (middleOne+1):(2*fewCount+1)
# #     lastFewIndices <- (nrow(station)-fewCount+1):nrow(station)
# #     barCount <- 2 * fewCount + 1
#     firstFew <- 1:15
#     middleOne <- 16
#     lastFewIndices <- nrow(station)
#     barCount <- 17
#     # NOTE:  One extra that will be in the middle
#     mat <- as.matrix(station[c(firstFew,middleOne,lastFewIndices),c('dailyFromUsage','dailyToUsage')])
#     mat[y_middleOne,] <- NA
#     labels <- as.character(c(station$name[firstFew],'...',station$name[lastFewIndices]))
#     
#     
#   } else {
#     firstFew <- (nrow(station)-2*fewCount):(nrow(station)-fewCount-1)
#     middleOne <- max(firstFew) + 1
#     lastFew <- (middleOne+1):(nrow(station))
#     lastFewIndices <- (nrow(station)-fewCount+1):nrow(station)
#     barCount <- 2 * fewCount + 1
#     # NOTE:  One extra that will be in the middle
#     mat <- as.matrix(station[c(firstFew,middleOne,lastFewIndices),c('dailyFromUsage','dailyToUsage')])
#     ###mat[y_middleOne,] <- NA
#     labels <- as.character(c(station$name[firstFew],station$name[middleOne],station$name[lastFewIndices]))
#   }
#   
#   # Modify daily/yearly based on maxValue
#   if (infoList$stationId == 'all') {
#     maxValue <- max(usage,na.rm=TRUE)
#   } else {
#     maxValue <- max(usage,na.rm=TRUE)
#   }
#   
#   if (maxValue > 900) {
#     factor <- 1/365
#     mat <- mat * factor
#     xlab <- 'visits/day'
#     textList$subset <- paste0(textList$subset,'  (max ',round(maxValue/365,1),'/day)')
#   } else {
#     factor <- 1
#     xlab <- 'visits/year'
#     textList$subset <- paste0(textList$subset,'  (max ',maxValue,'/year)')
#   }
#   
#   
#   # ----- Colors --------------------------------------------------------------
#   
#   # NOTE:  Sadly, barplot doesn't take a matrix defining every single color.
#   col_departure <- adjustcolor(RColorBrewer::brewer.pal(9,'Reds')[8], barOpacity)
#   col_arrival <- adjustcolor(RColorBrewer::brewer.pal(9,'Blues')[8], 0.5)
#   cols <- c(col_departure,col_arrival)
# 
#   
#   # ----- Layout --------------------------------------------------------------
#   
#   # NOTE:  The layoutFraction_ components are the same in every plot and guarantee
#   # NOTE:  a similar look and feel across plots. The fractions are multiplied by
#   # NOTE:  the sum of heights used by all other plotting rows in your plot.
#   # NOTE:
#   # NOTE:  For instance, if you have three plots with heights of c(2,1,1) then the
#   # NOTE:  full set of plotting heights is 4 and the full set of heights will be:
#   # NOTE:  heights=c(layoutFraction_title*4,2,1,1,layoutFraction_attribution*4).
#   # NOTE:
#   # NOTE:  The order of plotting should always start with N and end with N-1 so 
#   # NOTE:  that the title is added last.
#   
#   # For this plot the sum of heights is 1
#   plotHeightSum <- 1
#   heights <- c(plotHeightSum * infoList$layoutFraction_title,
#                rep(1,1),
#                plotHeightSum * infoList$layoutFraction_attribution)
#   layout(matrix(c(3,1:2)), heights=heights)
#   
# 
#   # ----- Plot ----------------------------------------------------------------
#   
#   par(mar=c(8,4,4,4))
#   
#   # NOTE:  barplot needs the transpose of the matrix and therefor also the
#   # NOTE:  reverse of the 
#   
#   # NOTE:  When we're looking at departure from a particular station only show arrivals.
#   if (infoList$stationId == 'all') {
#     locations <- barplot(t(mat), names.arg=rep(NA,barCount), horiz=TRUE,
#                        col=cols, border=adjustcolor('black',0.5),
#                        axes=FALSE, xlab='', ylab='')
#   } else {
#     locations <- barplot(mat[,2], names.arg=rep(NA,barCount), horiz=TRUE,
#                          col=col_arrival, border=adjustcolor('black',0.5),
#                          axes=FALSE, xlab='', ylab='')
#   }
#   
#   axis(1, lwd=lwd_axis, cex.axis=cex_axis, mgp=c(3,2.5,0), tcl=-1.0)
#   mtext(xlab, side=1, line=line_xlab, cex=cex_xlab, xpd=NA)
#   axis(3, lwd=lwd_axis, cex.axis=cex_axis, mgp=c(3,2,0), tcl=-1.0)
# 
#   # ----- Annotations ---------------------------------------------------------
#   
#   usr <- par('usr')
#   if (infoList$stationId == 'all') {
#     
#     xpos <- 1.1 * sum(mat[max(y_firstFew),])
#     if (xpos == 0) xpos <- usr[1] + 0.02 * (usr[2] -usr[1])
#     ypos <- locations[y_firstFew]
#     text(xpos, ypos, labels[y_firstFew], font=font_badStation, col=col_badStation, cex=cex_badStation, pos=4)
#     xpos <- usr[1] + 0.02 * (usr[2] -usr[1])
#     ypos <- locations[y_middleOne]
#     text(xpos, ypos, labels[y_middleOne], font=font_badStation, col=col_badStation, cex=cex_goodStation, pos=4)
#     xpos <- usr[1] + 0.02 * (usr[2] - usr[1])
#     ypos <- locations[y_lastFew]
#     text(xpos, ypos, labels[y_lastFew], font=font_goodStation, col=col_goodStation, cex=cex_goodStation, pos=4)
#     
#   } else {
#     
#     xpos <- usr[1] + 0.02 * (usr[2] -usr[1])
#     if (xpos == 0) xpos <- usr[1] + 0.02 * (usr[2] -usr[1])
#     ypos <- locations[y_firstFew]
#     text(xpos, ypos, labels[y_firstFew], font=font_badStation, col=col_badStation, cex=cex_badStation, pos=4)
#     # NOTE:  Overplotting this one for some reason.
# #     xpos <- usr[1] + 0.02 * (usr[2] -usr[1])
# #     ypos <- locations[y_middleOne]
# #     text(xpos, ypos, labels[y_middleOne], font=font_badStation, col=col_badStation, cex=cex_goodStation, pos=4)
#     xpos <- usr[1] + 0.02 * (usr[2] - usr[1])
#     ypos <- locations[y_lastFew]
#     text(xpos, ypos, labels[y_lastFew], font=font_goodStation, col=col_badStation, cex=cex_goodStation, pos=4)
#     
#   }
#   
#   xpos <- usr[1] + 0.7 * (usr[2] - usr[1])
#   ypos <- usr[3] + 0.2 * (usr[4] - usr[3])
#   legend(xpos,ypos,legend=c('Departures','Arrivals'),fill=cols,
#          text.font=1, col=text.col_badStation, cex=cex_legend)
#   
#   if (infoList$stationId != 'all') {
#     textList$title <- paste0('Destinations from ',infoList$stationId)
#   }
#   
#   # Add title and attribution as the last two plots
#   addTitleAndAttribution(dataList,infoList,textList)
#   
#   # ---- Cleanup and Return ---------------------------------------------------
#  
#   # Restore Global Graphical Parameters
#   par(mar=c(5,4,4,2)+.1)
#   layout(1)
#   
#   return(c(1.0,2.0,3.0,4.0))

}
