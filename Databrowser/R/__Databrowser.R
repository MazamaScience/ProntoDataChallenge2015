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
source("__DATABROWSER_PATH__/R/growthPlot.R")

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
  
  # This section isn't called in the map example
  if (infoList$plotType != "Map") {
    
    absPlotPDF <- paste(infoList$outputDir,infoList$outputFileBase,'.pdf',sep="")
    absPlotPNG <- paste(infoList$outputDir,infoList$outputFileBase,'.png',sep="")
    
    if (infoList$plotDevice == "pdf") {
      
      width <- 8
      height <- width * infoList$plotHeight/infoList$plotWidth
      pdf(file=absPlotPDF, width=width, height=height, bg='white')
      print(paste("Working on",absPlotPDF))
      
    } else if (infoList$plotDevice == "cairo") {
      
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
  
  if (infoList$plotType == 'growth') {
    
    returnValues <- growthPlot(dataList,infoList,textList)
    
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
  
  
  # ----- Convert PDF file to PNG file using ImageMagick ----------------------
  
  if (infoList$plotDevice == "pdf") {
    
    gs_cmd <- paste("gs -dSAFTER -dBATCH -dNOPAUSE -sDEVICE=png16m ",
                    "-dGraphicsAlphaBits=4 -dTextAlphaBits=4 -r300 ",
                    "-dBackgroundColor='16#ffffff' ",
                    "-sOutputFile=",absPlotPNG," ",absPlotPDF," > /dev/null",
                    sep="")
    result <- system(gs_cmd)
    
    # ImageMagick version of mogrify
    mogrify_cmd <- paste("mogrify -resize ", infoList$plotWidth, "x",
                         infoList$plotHeight, " ", absPlotPNG,
                         " > /dev/null", sep="")
    
    # GraphicsMagick version of mogrify
    #mogrify_cmd <- paste("gm mogrify -resize ", infoList$plotWidth, "x",
    #                     infoList$plotHeight, " ", absPlotPNG,
    #                     " > /dev/null", sep="")
    
    result <- system(mogrify_cmd)
    
    elapsed <- ( (proc.time())[3] - timepoint )
    timepoint <- (proc.time())[3]
    print(paste(round(elapsed,4),"seconds to convert PDF to PNG"))
    
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
