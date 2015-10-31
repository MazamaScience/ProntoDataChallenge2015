###############################################################################
# pie_user.R
#
# Displays a simple pie plot broken down by userType

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
  infoList$ProntoSlate <- '#003B49'
  infoList$ProntoTurquoise <- '#68D2DF'
  
  dataList <- createDataList(infoList)
  
  textList <- createTextList(dataList,infoList)
  
  
  
  
  pie_user(dataList, infoList, textList)
  
  
  
  
  
}

pie_user <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------
  
  # Overall
  font_label <- 2
  cex_label <- 6
  col_label <- 'white'
  
  font_center <- 2
  cex_center <- 8
  col_center <- infoList$col_subtitle
  
  colors <- c(infoList$ProntoSlate, infoList$ProntoGreen)
  
  
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  
  table <- table(trip$userType)
  sumValue <- sum(table)
  
  memberPct <- round(100 * table['Annual Member'] / sumValue)
  shortTermPct <- round(100 * table['Short-Term Pass Holder'] / sumValue)
  
  
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
  
  par(mar=c(2,2,2,2))
  
  # Algorithm to center 'Annual Member' at top of plot
  midMemberFraction <- table['Annual Member'] / 2
  init.angle <- (midMemberFraction/sumValue)*360 + 90
  
  # Colored donut
  pie(table, border='white', labels=NA, col=colors,
      rad=1.0, clockwise=T, init.angle=init.angle)
  
  par(new=TRUE)
  
  pie(c(1), border='white', labels=NA, rad=0.5)
  par(new=FALSE)
  
  
  # ----- Annotations ---------------------------------------------------------
  
  text(0, 0.75, paste0(memberPct,'%\n',textList$annual), col=col_label, cex=cex_label, font=font_label)
  text(0, -0.70, paste0(shortTermPct,'%\n',textList$shortTerm), col=col_label, cex=cex_label, font=font_label)
  text(0, 0, paste0(prettyNum(sumValue, big.mark=','),'\n',textList$trips),
       col=col_center, cex=cex_center, font=font_center)
  
  
  # Add title and attribution as the last two plots
  addTitleAndAttribution(dataList,infoList,textList)
  
  # ---- Cleanup and Return ---------------------------------------------------
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))
  
}
