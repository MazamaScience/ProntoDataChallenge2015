###############################################################################
# addTitleAndAttribution.R
#
# Adds the Title and Attribution as the last two plots.

addTitleAndAttribution <- function(dataList, infoList, textList) {
  
  # ---- Title and Attribution ------------------------------------------------
  
  par(mar=c(0,0,0,0))
  
  # Attribution at the bottom
  plot(0:1,0:1,col='transparent',axes=FALSE,xlab='',ylab='')
  text(0.5, 0.5, textList$attribution, 
       font=infoList$font_attribution,
       col=infoList$col_attribution,
       cex=infoList$cex_attribution, xpd=NA)
  
  # Title and subset information at the top
  plot(0:1,0:1,col='transparent',axes=FALSE,xlab='',ylab='')
  text(0.5, 0.7, textList$title,
       font=infoList$font_title,
       col=infoList$col_title,
       cex=infoList$cex_title, xpd=NA)
  text(0.5, 0.2, textList$subset,
       font=infoList$font_subtitle,
       col=infoList$col_subtitle,
       cex=infoList$cex_subtitle, xpd=NA)
  
  # Restore Global Graphical Parameters
  par(mar=c(5,4,4,2)+.1)
  
}
