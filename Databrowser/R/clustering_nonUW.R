###############################################################################
# clustering_nonUW.R
#
# Displays ...

###############################################################################
# Intialization for testing in RStudio

if (FALSE) {

  
  library(dplyr)
  library(reshape2)
  
  
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

  clustering_nonUW(dataList, infoList, textList)
  
  
  
  
  
}

  library(dplyr)
  library(reshape2)

clustering_nonUW <- function(dataList, infoList, textList) {
  
  # ----- Style ---------------------------------------------------------------

  # Overall
  font_label <- 1
  cex_label <- 1
  col_label <- 'gray20'
  
  cex_title <- 2
  
  # ----- Data Preparation ----------------------------------------------------
  
  # Get dataframe from the dataList
  trip <- dataList$trip
  
  # Remove Pronto Station, UW-, UD- and EL-05
  Childrens_from <- stringr::str_detect(trip$fromStationId,"DPD-03")
  Childrens_to <- stringr::str_detect(trip$toStationId,"DPD-03")
  Childrens <- Childrens_from | Childrens_to
  Pronto_from <- stringr::str_detect(trip$fromStationId,"XXX-01")
  Pronto_to <- stringr::str_detect(trip$toStationId,"XXX-01")
  Pronto <- Pronto_from | Pronto_to
  UW_from <- stringr::str_detect(trip$fromStationId,"UW-")
  UW_to <- stringr::str_detect(trip$toStationId,"UW-")
  UW <- UW_from | UW_to
  UD_from <- stringr::str_detect(trip$fromStationId,"UD-")
  UD_to <- stringr::str_detect(trip$toStationId,"UD-")
  UD <- UD_from | UD_to
  EL_05_from <- stringr::str_detect(trip$fromStationId,"EL-05")
  EL_05_to <- stringr::str_detect(trip$toStationId,"EL-05")
  EL_05 <- EL_05_from | EL_05_to
  
  # Apply mask
  mask <- !Childrens & !Pronto & !UW & !UD & !EL_05
  trip <- trip[mask,]
  
  # All combinations of from-to stations
  trip %>% 
    group_by(fromStationId,toStationId) %>%
    summarize(count=n()) ->
    from_to_stations
  
  # Create a matrix for a heatmap
  melted <- reshape2::melt(from_to_stations, measure.vars='count')
  cohort <- intersect(melted$toStationId, melted$fromStationId)
  melted <- subset(melted, toStationId %in% cohort & fromStationId %in% cohort)
  from_to_df <- reshape2::dcast(melted, fromStationId ~ toStationId)
  from_to_df[is.na(from_to_df)] <- 0
  from_to_matrix <- as.matrix(from_to_df[,-1])
  labRow <- as.character(from_to_df[,1])
  labCol <- colnames(from_to_df)[-1]
  
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
  
#   # For this plot the sum of heights is 1
#   plotHeightSum <- 1
#   heights <- c(plotHeightSum * infoList$layoutFraction_title,
#                rep(1,1),
#                plotHeightSum * infoList$layoutFraction_attribution)
#   layout(matrix(c(3,1:2)), heights=heights)
  

  # ----- Plot ----------------------------------------------------------------
  
  par(mar=c(5,4,4,2)+.1)
  
  #----------------------------------------------------
  
  
#   # Add colors for the most important stations
#   NUM_CATEGORIES <- 5
#   fromCount <- rowSums(from_to_matrix)
#   fromCodes <- .bincode(fromCount,
#                         breaks=quantile(fromCount, probs=seq(0,1,length.out=NUM_CATEGORIES+1)),
#                         include.lowest=TRUE)
#   fromColors <- rev(heat.colors(NUM_CATEGORIES))[fromCodes]
#   
#   toCount <- colSums(from_to_matrix)
#   toCodes <- .bincode(toCount,
#                       breaks=quantile(toCount, probs=seq(0,1,length.out=NUM_CATEGORIES+1)),
#                       include.lowest=TRUE)
#   toColors <- rev(heat.colors(NUM_CATEGORIES))[toCodes]
  
  heatmap(t(as.matrix(from_to_matrix)),col=RColorBrewer::brewer.pal(9,'Purples'),
          margins=c(6,6),
          xlab='From Station', ylab='To Station',            # confusion here?
          #xlab='From Station', ylab='To Station', symm=TRUE, # confusion here?
          #Rowv=NA, Colv=NA, # to remove reordering for culstering
          #ColSideColors=toColors, # NOTE:  Total trips breaks are linear (heatmap exponential?)
          #RowSideColors=fromColors, # NOTE:  Total trips
          labRow=labRow, labCol=labCol)
  
  title(main=textList$title, cex.main=cex_title)
  
#   # Add title and attribution as the last two plots
#   addTitleAndAttribution(dataList,infoList,textList)
  
  # ---- Cleanup and Return ---------------------------------------------------
 
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  layout(1)
  
  return(c(1.0,2.0,3.0,4.0))

}
