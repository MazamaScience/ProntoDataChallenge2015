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

# Include all the supporting code
source("__DATABROWSER_PATH__/R/createInfoList.R")
source("__DATABROWSER_PATH__/R/createDataList.R")

source("__DATABROWSER_PATH__/R/weeklyUsageByDayOfWeekPlot.R")
source("__DATABROWSER_PATH__/R/dailyUsageByHourOfDayPlot.R")
source("__DATABROWSER_PATH__/R/stationBubblePlot.R")

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
    
  absPlotPNG <- paste(infoList$outputDir,infoList$outputFileBase,'.png',sep="")
  
  # NOTE:  The stationBubblePlot uses RgoogleMaps::GetMap() to obtain the
  # NOTE:  initial png file from Google.
  
  if (infoList$plotType != "stationBubble") {
    
    if (infoList$plotDevice == "cairo") {
      
      library(Cairo) # CairoPNG is part of the Cairo package
      CairoPNG(filename=absPlotPNG,
               width=infoList$plotWidth, height=infoList$plotHeight,
               units='px', bg='white')
      print(paste("Working on", absPlotPNG))
      
    } else if (infoList$plotDevice == "png") {
      
      png(filename=absPlotPNG,
          width=infoList$plotWidth, height=infoList$plotHeight,
          units='px', bg='white')
      print(paste("Working on",absPlotPNG))
      
    }
    
  }
  
  
  # ----- Subset the data -----------------------------------------------------
  
  
  # ----- Harmonize the data --------------------------------------------------
  
  
  # ----- Create the desired output -------------------------------------------
  
  returnValues <- c(0.0,0.0,0.0,0.0)
  
  if (infoList$plotType == 'weeklyUsageByDayOfWeek') {
    
    returnValues <- weeklyUsageByDayOfWeekPlot(dataList,infoList,textList)
    
  } else if (infoList$plotType == "dailyUsageByHourOfDay") { 
    
    returnValues <- dailyUsageByHourOfDayPlot(dataList,infoList,textList)
    
  } else if (infoList$plotType == "stationBubble") { 
    
    returnValues <- stationBubblePlot(dataList,infoList,textList)
    
  } else if (infoList$plotType == "Map") { 
    
    returnValues <- mapPlot(dataList,infoList,textList)
    
  } else {
    
    stop(paste0("ERROR in __Databrowser.R: plotType=",infoList$plotType," is not recognized."),call.=FALSE)
    
  }
  
  plotSecs <- elapsed <- ( (proc.time())[3] - timepoint )
  timepoint <- (proc.time())[3]
  print(paste(round(elapsed,4),"seconds to plot the data"))
  
  
  # ----- Cleanup -------------------------------------------------------------
  
  totalSecs <- ( (proc.time())[3] - start )
  print(paste("Total elapsed =",round(totalSecs,4),"seconds"))
  
  if (infoList$plotDevice != '' & infoList$plotType == "TrigFunctions") {
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
