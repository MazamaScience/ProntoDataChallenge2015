########################################################################
# createDataList.R
#
# Databrowser specific creation of dataframes for inclusion in dataList.
#
# Author: Jonathan Callahan
########################################################################

createDataList <- function(infoList) {
  
  # Load data
  df <- get(load(paste0(infoList$dataDir,'/Mazama_trip.RData')))
  
  # Subset data
  
  if (!is.null(infoList$MazamaSubset)) {
    # Back-door for hand typed subsets
    
    df <- subset(df, eval(parse(text=infoList$MazamaSubset))) # No checks done so typos result in errors
    
  } else {
    # Front-door for everyone else
    
    if (!is.null(infoList$userType)) df <- subset(df, userType == infoList$userType)
    if (!is.null(infoList$gender))   df <- subset(df, gender == infoList$gender)
    #   if (!is.null(infoList$weekday_weekend)) {
    #     if (infoList$weekday_weekend == 'weekday') {
    #       df <- df[df$dayOfWeek <= 5]
    #     } else {
    #       df <- df[df$dayOfWeek >= 6,]
    #     }
    #   }
    
  }
  
  # Create dataList
  dataList <- list(df=df)
  
  return(dataList)
  
}

