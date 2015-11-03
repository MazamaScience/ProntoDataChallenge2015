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
  cex_label <- 1
  col_label <- 'gray20'
  
  ### ADD STUFF HERE
  ### ADD STUFF HERE
  ### ADD STUFF HERE
  
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip


  # Convert days from 00:00-23:00 to 04:00-27:00 by setting all times back four hours
  startTime <- trip$startTime - lubridate::dhours(3)

  # Create a dataframe with just "minuteOfDay" and "elevationGain" columns
  trip$minuteOfDay <- 60 * lubridate::hour(startTime) + lubridate::minute(startTime) + 1

  trip %>% select(minuteOfDay,elevationDiff) %>% 
    group_by(minuteOfDay) %>% 
    summarise(elevationGain=sum(elevationDiff)) %>% 
    arrange(minuteOfDay) -> elevationDay
  
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
  
  par(mar=c(5,4,4,2)+.1)
  
  
  plot(elevationDay$minuteOfDay, cumsum(elevationDay$elevationGain), xlim=c(1,60*24), type='s')
  

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
