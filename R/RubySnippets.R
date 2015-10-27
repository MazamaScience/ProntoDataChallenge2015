# Exploring Pronto Data



dawnDuskPiePlot <- function(df, centerText='Daytime\nis\nBiketime!') {
  counts <- as.numeric(table(df$solarPosition))
  middayFraction <- counts[[2]]/2 + counts[[1]]
  init.angle <- (middayFraction/sum(counts))*360 + 90
  colors <- c('#E77483', 'gold', 'orange', 'gray31')
  pie(table(df$solarPosition), border='white', col=colors, clockwise=T, init.angle=init.angle)
  par(new=TRUE)
  pie(c(1), border='white', labels=NA, rad=0.4)
  text(0,0, labels=centerText, cex=1.25, font=2)
  par(new=FALSE)
}

layout(matrix(c(1,3,2,4), nrow=2, ncol=2))

dawnDuskPiePlot(subset(trip, gender=='Female'), centerText='Female\nAnnual\nMembers')
dawnDuskPiePlot(subset(trip, gender=='Male'), centerText='Male\nAnnual\nMembers')

pie(1,border='gray80', col='gray80', labels=NA)

