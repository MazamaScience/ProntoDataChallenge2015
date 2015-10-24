############################################################
# trigFunctionsPlot
#

trigFunctionsPlot <- function(dataList, infoList, textList) {

  ########################################
  # Extract data from 'dataList' object 
  ########################################

  timepoint <- (proc.time())[3]

  ########################################
  # Extract variables from the 'infoList' object
  ########################################

  # Extra information
  plotType <- ifelse(is.null(infoList$plotType),'TrigFunctions',infoList$plotType)
  plotWidth <- as.numeric( ifelse(is.null(infoList$plotWidth),'500',infoList$plotWidth) )
  trigFunction <- ifelse(is.null(infoList$trigFunction),'cos',infoList$trigFunction)
  lineColor <- ifelse(is.null(infoList$lineColor),'black',infoList$lineColor)
	cycles    <- as.numeric(infoList$cycles)

  ########################################
  # Set up style
  ########################################

  mar <- c(5, 4, 4, 2) + 0.1 # default is c(5,4,4,2)+0.1
  par(mar=mar)

  lwd <- 1
  col <- lineColor

  attribution_line <- 4.0
  attribution_col <- 'grey50'
  attribution_cex <- 1.0

  ########################################
  # Plot the data
  ########################################

  if (trigFunction == 'cos') {
    func <- cos
  } else if (trigFunction == 'sin') {
    func <- sin
  } else if (trigFunction == 'tan') {
    func <- tan
  } else if (trigFunction == 'acos') {
    func <- acos
  } else if (trigFunction == 'asin') {
    func <- asin
  } else if (trigFunction == 'atan') {
    func <- atan
  } else {
    stop(paste0("ERROR in trigFunctionsPlot.R: trigFunction '",trigFunction,"' is not recognized."),call.=FALSE)
  }

  plot(func, 0, cycles*2*pi, lwd=lwd, col=col)  
  

  ##################################################
  # Add labeling only if site viewed on large screen
  ##################################################

  if (plotWidth > 480) {
	  
	  
    # title
    title(main=textList$title)

    # attribution
    mtext(textList$attribution, side=1,
          line=attribution_line,
          cex=attribution_cex, col=attribution_col)

    elapsed <- ( (proc.time())[3] - timepoint )
    timepoint <- (proc.time())[3]
    print(paste("..",round(elapsed,4),"seconds to create a plot"))
  } 

  ########################################
  # Return values
  ########################################

  return(c(1.0,2.0,3.0,4.0))

}

