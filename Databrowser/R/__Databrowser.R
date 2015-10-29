################################################################################
# __DATABROWSER__.R
#
# Author: Jonathan Callahan
################################################################################

# Modify library search path to look for packages installed with the databrowser
.libPaths( c("__DATABROWSER_PATH__/R/library",.libPaths()) )

# Required R packages
library(stringr) # for sane string manipulations
library(jsonlite) # for JSON support

# Turn warnings into errors
options(warn=2)

result <- try( {
  # Include all the supporting code
  source("__DATABROWSER_PATH__/R/createInfoList.R")
  source("__DATABROWSER_PATH__/R/createDataList.R")
  
  source("__DATABROWSER_PATH__/R/addTitleAndAttribution.R")

  source("__DATABROWSER_PATH__/R/barplot_weekByDayPlot.R")
  source("__DATABROWSER_PATH__/R/bubble_stationPlot.R")
  source("__DATABROWSER_PATH__/R/calendar_weatherPlot.R")
  source("__DATABROWSER_PATH__/R/heatmap_weekByDayPlot.R")
  source("__DATABROWSER_PATH__/R/heatmap_weekByHourPlot.R")
  source("__DATABROWSER_PATH__/R/pie_daylightPlot.R")
}, silent=TRUE)

if ( class(result)[1] == "try-error" ) {
  # Obtain the "cannot open file ..." information
  err_msg <- geterrmessage()
  if ( stringr::str_detect(err_msg,"cannot open file.*$") ) {
    err_msg <- stringr::str_match(err_msg,"cannot open file.*$")[1,1]
    err_msg <- paste0('---------- ',stringr::str_trim(err_msg))
  }
  stop(err_msg, call.=FALSE)
}

# Turn warnings into immediate warnings
options(warn=1)

# Global variables
G_DEBUG <- TRUE

################################################################################
# Databrowser function

__DATABROWSER__ <- function(jsonArgs='{}') {
  
  start <- (proc.time())[3]
  timepoint <- (proc.time())[3]
  
  # ----- Create the infoList from the jsonArgs --------------------------------
  
  infoList <- createInfoList(jsonArgs)
  
  # Add directories determined from Makefile settings
  infoList$scriptDir <- "__DATABROWSER_PATH__/R/"
  infoList$dataDir <- "__DATABROWSER_PATH__/data/"
  infoList$outputDir <- "__DATABROWSER_PATH__/__OUTPUT_DIR__/"
  
  
  # ----- Read in the appropriate data -----------------------------------------
  
  dataList <- createDataList(infoList)
  
  loadSecs <- elapsed <- ( (proc.time())[3] - timepoint )
  timepoint <- (proc.time())[3]
  print(paste(round(elapsed,4),"seconds to load the data"))
  
  
  # ----- Create textList with language dependent strings for plot annotation --
  
  textListScript = paste('__DATABROWSER_PATH__/R/createTextList_',
                         infoList$language, '.R', sep="")
  source(textListScript)
  textList = createTextList(dataList, infoList)
  
  
  # ----- Create the png file --------------------------------------------------
    
#   absPlotPNG <- paste(infoList$outputDir,infoList$outputFileBase,'.png',sep="")
#   
#   if (infoList$plotDevice == "cairo") {
#       
#     library(Cairo) # CairoPNG is part of the Cairo package
#     CairoPNG(filename=absPlotPNG,
#              width=infoList$plotWidth, height=infoList$plotHeight,
#              units='px', bg='white')
#     print(paste("Working on", absPlotPNG))
#       
#   } else if (infoList$plotDevice == "png") {
#       
#     png(filename=absPlotPNG,
#         width=infoList$plotWidth, height=infoList$plotHeight,
#         units='px', bg='white')
#     print(paste("Working on",absPlotPNG))
#       
#   }
#   
  
  # ----- Subset the data -----------------------------------------------------
  
  
  # ----- Harmonize the data --------------------------------------------------
  
  
  # ----- Create the desired output -------------------------------------------
  
  if (infoList$productType == "systemTable") {
    
#     plotDict <- list(barplotDayByWeek = barplotDayByWeekPlot,
#                      weatherCalendar = weatherCalendarPlot,
#                      heatmapHourByDay = heatmapHourByDayPlot,
#                      heatmapHourByWeek = heatmapHourByWeekPlot,
#                      daylight = daylightPlot,
#                      stationBubble = stationBubblePlot,
#                      map = mapPlot)
#     
    
    for (plotType in as.character(infoList$plotTypes[[1]])) {
      
      print("First element:")
      print(plotType)
      
      absPlotPNG <- paste(infoList$outputDir,infoList$outputFileBase,'_',plotType,'.png',sep="")
      png(filename=absPlotPNG,
          width=infoList$plotWidth, height=infoList$plotHeight,
          units='px', bg='white')
  
      returnValues <- c(0.0,0.0,0.0,0.0)
      
      if (plotType == 'barplotDayByWeek') {
        
        returnValues <- barplotDayByWeekPlot(dataList,infoList,textList)
        
      } else if (plotType == "weatherCalendar") { 
        
        returnValues <- weatherCalendarPlot(dataList,infoList,textList)
        
      } else if (plotType == "heatmapHourByDay") { 
        
        returnValues <- heatmapHourByDayPlot(dataList,infoList,textList)
    
      } else if (plotType == "heatmapHourByWeek") { 
        
        returnValues <- heatmapHourByWeekPlot(dataList,infoList,textList)
    
      } else if (plotType == "weatherCalendar") { 
        
        returnValues <- weatherCalendarPlot(dataList,infoList,textList)
        
      } else if (plotType == "daylight") { 
        
        returnValues <- daylightPlot(dataList,infoList,textList)
        
      } else if (plotType == "stationBubble") { 
        
        returnValues <- stationBubblePlot(dataList,infoList,textList)
        
      } else if (plotType == "Map") { 
        
        returnValues <- mapPlot(dataList,infoList,textList)
        
      } else {
        
        stop(paste0("ERROR in __Databrowser.R: plotType=",plotType," is not recognized."),call.=FALSE)
        
      }
      
    }

  }
  
  plotSecs <- elapsed <- ( (proc.time())[3] - timepoint )
  timepoint <- (proc.time())[3]
  print(paste(round(elapsed,4),"seconds to plot the data"))
  
  
  # ----- Cleanup -------------------------------------------------------------
  
  totalSecs <- ( (proc.time())[3] - start )
  print(paste("Total elapsed =",round(totalSecs,4),"seconds"))
  
  if ( infoList$plotDevice != '' ) {
    dev.off()
  }
  
  
  # ----- Return ---------------------------------------------------------------
  
  # NOTE:  An object of any type may be returned.
  # NOTE:  This object will be serialized to JSON and will be passed back to the
  # NOTE:  user interface. The javascript code in __Mazama_databrowser.js must
  # NOTE:  then interpret and use the JSON object.
  
  returnValues <- list(loadSecs=as.numeric(loadSecs),
                       plotSecs=as.numeric(plotSecs),
                       totalSecs=as.numeric(totalSecs),
                       returnValues=returnValues)
  
  returnJSON <- toJSON(returnValues)
  
  return(returnJSON)
  
}

################################################################################
# END
################################################################################
