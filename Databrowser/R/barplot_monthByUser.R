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
  
  
  barplot_monthByUser(dataList, infoList, textList)
  
  
  
  
  
}

barplot_monthByUser <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------
  
  # Overall
  font_label <- 2
  cex_label <- 4
  cex_userLabel <- 4
  col_label <- 'gray20'
  
  # Bars
  barExpansion <- 1.0
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  
  # Create a table of # of rides
  tbl <- table(trip$month, trip$userType)
  
  # Convert the table (it's 1-D) into a matrix so we can rearrange the rows
  mat <- matrix(tbl,nrow=12,byrow=FALSE)
  maxValue <- max(mat, na.rm=TRUE)
  sumValue <- sum(mat, na.rm=TRUE)
  
  # TODO:  Create a ProntoMonth in the trip dataframe
  
  monthSums <- rowSums(mat)
  monthMax <- max(monthSums)
    
  
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
  
  monthIndices <- 1:12 # Jan - Dec
  
  # Annual Members on the top
  par(mar=c(0.5,1,1,1))
  barplotMatrix <- barplot(mat[monthIndices,1]*barExpansion,
                           ylim=c(0,monthMax),                                                   
                           axes=FALSE, xlab='', ylab='',
                           border='white', space=.1,
                           col=infoList$ProntoSlate)

  text(par('usr')[2],monthMax/2, paste0(textList$annual), pos=2,
       col=col_label, cex=cex_userLabel, font=font_label)

  
  # Short-Term Members on the bottom
  par(mar=c(1,1,0.5,1))
  barplotMatrix <- barplot(-mat[monthIndices,2]*barExpansion,
                           ylim=c(-1*monthMax,0),                           
                           axes=FALSE, xlab='', ylab='',
                           border='white', space=.1,
                           col=infoList$ProntoGreen)
  
  text(par('usr')[2],-monthMax/2, paste0(textList$shortTerm), pos=2,
       col=col_label, cex=cex_userLabel, font=font_label)
    

  # ----- Add month labels ----------------------------------------------------

  xposIndices <- 1:12
  xpos <- barplotMatrix[xposIndices,1]
  # TODO:  Use names from textList when they start with January
  labels <- c('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')
  text(xpos-0.4, -monthMax*0.88, labels, pos=4,
       col=col_label, cex=cex_label, font=font_label)
  
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))
  
}
