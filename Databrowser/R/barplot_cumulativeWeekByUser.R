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
  
  
  
  

  barplot_hourByUser_Plot(dataList, infoList, textList)
 
  
  
  
  
}

barplot_cumulativeWeekByUser_Plot <- function(dataList, infoList, textList) {
  
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
  table <- table(trip$ProntoWeek, trip$userType)
  ### table <- table(trip$gender, trip$hourOfDay) 
  ### barplot(table)

  # Convert the table (it's 1-D) into a matrix so we can rearrange the rows
  mat <- matrix(table,nrow=53,byrow=FALSE)
#   maxValue <- max(mat, na.rm=TRUE)
#   sumValue <- sum(mat, na.rm=TRUE)
  
  cumAnnual <- 
  
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
  
  par(mar=c(1,1,1,1))
  
  
  

  ### ADD STUFF HERE
  ### ADD STUFF HERE
  ### ADD STUFF HERE
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  # ---- Cleanup and Return ---------------------------------------------------
 
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))

}
