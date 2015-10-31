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
  infoList$ProntoGreen <- '#8EDD65'
  infoList$ProntoTurquose <- '#68D2DF'
  infoList$ProntoSlate <- '#063C4A'
  
  
  dataList <- createDataList(infoList)
  
  textList <- createTextList(dataList,infoList)
  
  
  
  
  
  barplot_hourByUser(dataList, infoList, textList)
  
  
  
  
  
}

barplot_hourByUser <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------
  
  # Overall
  font_text <- 2
  cex_text <- 4
  cex_userLabel <- 4
  col_text <- 'gray20'
  
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  
  # Create a table of # of rides
  tbl <- table(trip$hourOfDay, trip$userType)
  
  # Convert the table (it's 1-D) into a matrix so we can rearrange the rows
  mat <- matrix(tbl,nrow=24,byrow=FALSE)
  maxValue <- max(mat, na.rm=TRUE)
  sumValue <- sum(mat, na.rm=TRUE)
  
  # NOTE:  To get the day to start at 4am we shift by 5 because the first hour is 0.
  # NOTE:  For hours on the vertical axis, reverse to get 4 am at the top.
  #hourIndices <- rev(c(5:24,1:4)) # top to bottom 
  hourIndices <- c(5:24,1:4)      # left to right
  
  hourSums <- rowSums(mat)
  hourMax <- max(hourSums)
  
  #   # TODO:  get nice measure lines
  #   measureLines <- seq(0,hourMax,5000)
  
  
  
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
               rep(1,2),
               plotHeightSum * infoList$layoutFraction_attribution)
  layout(matrix(c(4,1:3)), heights=heights)
  
  
  # ----- Plot ----------------------------------------------------------------
  
  # Annual Members on the top
  par(mar=c(0.5,1,1,1))
  barplotMatrix <- barplot(mat[hourIndices,1],
                           ylim=c(0,hourMax),                                                   
                           axes=FALSE, xlab='', ylab='',
                           border='white', space=.1,
                           col=infoList$ProntoSlate)

  text(par('usr')[2],hourMax/2, paste0(textList$annual), pos=2,
       col=col_text, cex=cex_userLabel, font=font_text)

  
  # Short-Term Members on the bottom
  par(mar=c(1,1,0.5,1))
  barplotMatrix <- barplot(-mat[hourIndices,2],
                           ylim=c(-1*hourMax,0),                           
                           axes=FALSE, xlab='', ylab='',
                           border='white', space=.1,
                           col=infoList$ProntoGreen)
  
  text(par('usr')[2],-hourMax/2, paste0(textList$shortTerm), pos=2,
       col=col_text, cex=cex_userLabel, font=font_text)
    

  # ----- Add hour labels ---------------------------------------------------

  if (infoList$timeOfDay == 'early') {
    times <- c(4,6); xposIndices <- times-3; labels <- c('4 am','6 am')
  } else if (infoList$timeOfDay == 'amCommute') {
    times <- c(7,9); xposIndices <- times-3; labels <- c('7 am','9 am')
  } else if (infoList$timeOfDay == 'midday') {
    times <- c(10,15); xposIndices <- times-3; labels <- c('10 am','3 pm')
  } else if (infoList$timeOfDay == 'pmCommute') {
    times <- c(16,18); xposIndices <- times-3; labels <- c('4 pm','6 pm')
  } else if (infoList$timeOfDay == 'evening') {
    times <- c(19,22); xposIndices <- times-3; labels <- c('7 pm','10 pm')
  } else if (infoList$timeOfDay == 'night') {
    times <- c(23,3); xposIndices <- c(20,23); labels <- c('11 pm','3 am')
  } else {
    times <- c(8,17); xposIndices <- times-3; labels <- c('8 am','5 pm')
  }
  
  xpos <- barplotMatrix[xposIndices,1]
  text(xpos,-hourMax*0.80, '|', pos=3,
       col=col_text, cex=cex_text, font=font_text)
  text(xpos-0.4,-hourMax*0.88, labels, pos=4,
       col=col_text, cex=cex_text, font=font_text)
  
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))
  
}
