
# This is an example of how to return a JSON file to JS based on 
# incoming parameteres. This code returns a different list depending
# on which plot type the user selects. There is no need to actually
# do this in R but it's an easy example to modify.

mapPlot <- function(dataList, infoList, textList) {
  
  statePlotType <- ifelse(is.null(infoList$statePlot),'population',infoList$statePlotType)
  
  stateData <- dataList$stateData
  
  # Return a different portion of the dataset depending on which plot type
  # is called
  if(statePlotType == "population") {
    return(stateData[1,])
  } else if(statePlotType == "area") {
    return(stateData[2,])
  } else if(statePlotType == "populationDensity") {
    return(stateData[1,] / stateData[2,])
  } else {
    stop(paste0("ERROR in mapPlot.R: plot '",trigFunction,"' is not recognized."),call.=FALSE)
  }

}

