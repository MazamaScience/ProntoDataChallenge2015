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
  font_label <- 1
  cex_label <- 1
  col_label <- 'gray20'
  
  # ...
  col_annual <- adjustcolor(infoList$ProntoSlate, 0.6)
  col_shortTerm <- adjustcolor(infoList$ProntoGreen, 0.6)
  
  ### ADD STUFF HERE
  ### ADD STUFF HERE
  ### ADD STUFF HERE
  
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip

  # Create a table of # of rides
  table <- table(trip$hourOfDay, trip$userType)
  ### table <- table(trip$gender, trip$hourOfDay) 
  ### barplot(table)

  # Convert the table (it's 1-D) into a matrix so we can rearrange the rows
  mat <- matrix(table,nrow=24,byrow=FALSE)
  maxValue <- max(mat, na.rm=TRUE)
  sumValue <- sum(mat, na.rm=TRUE)
  
  
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
#   plotHeightSum <- 1
#   heights <- c(plotHeightSum * infoList$layoutFraction_title,
#                rep(1,1),
#                plotHeightSum * infoList$layoutFraction_attribution)
#   layout(matrix(c(3,1:2)), heights=heights)
  

  # ----- Plot ----------------------------------------------------------------
  
  
  
  layout(matrix(c(2,1),ncol=2))
  
  # NOTE:  To get the day to start at 4am we shift by 5 because the first hour is 0.
  # NOTE:  For hours on the vertical axis, reverse to get 4 am at the top.
  hourIndices <- rev(c(5:24,1:4))
  
  table <- table(trip$userType, trip$hourOfDay) 
  #barplot(table[,c(5:24,1:4)], col=c(col_annual,col_shortTerm), border='white', space=0)
  
  par(mar=c(2,0,2,2))
  
  hourSums <- rowSums(mat)
  hourMax <- max(hourSums)
  
  # TODO:  get nice measure lines
  measureLines <- seq(0,hourMax,5000)
  
  barplotMatrix <- barplot(hourSums[hourIndices], horiz=TRUE,
                          axes=FALSE, xlab='', ylab='',
                          border='white', space=.1)
  
  #   barplot(rowSums(mat)[hourIndices], add=TRUE,
#                        col='transparent',
#                        border='black', space=.1)

  ###abline(v=measureLines, col='white',lwd=1)
  
  # Hours
  xpos <- 0
  ypos <- as.numeric(barplotMatrix) # TODO:  Adjust based on par('usr') settings
  text(xpos, ypos, 0:23, col='white', pos=4, xpd=NA)
  
  
  
  par(mar=c(2,2,2,2))

    # "Annual Member" in column 1
  barplot(-1.0*mat[hourIndices,1], xlim=c(-hourMax*1.05,0), horiz=TRUE,
          axes=FALSE, xlab='', ylab='',
          border='white', space=.05,
          col=col_annual)
  
  # "Short-Term Pass Holder" in column 2
  barplot(-1.0*mat[hourIndices,2], add=TRUE, horiz=TRUE,
          axes=FALSE, xlab='', ylab='',
          border='white', space=.05,
          col=col_shortTerm)
  
  abline(v=-1.0*measureLines, col='white',lwd=1)
  

  ### ADD STUFF HERE
  ### ADD STUFF HERE
  ### ADD STUFF HERE
  
  # Add title and attribution as the last two plots
###  addTitleAndAttribution(dataList,infoList,textList)
  
  # ---- Cleanup and Return ---------------------------------------------------
 
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))

}
