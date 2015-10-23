# Exploring Pronto Data



dawnDuskPiePlot <- function(df, centerText='Daytime\nis\nBiketime!') {
  colors <- c('#E77483', 'gold', 'orange', 'gray31')
  pie(table(df$solarPosition), border='white', col=colors, clockwise=T, init.angle=246)
  par(new=TRUE)
  pie(c(1), border='white', labels=NA, rad=0.4)
  text(0,0, labels=centerText, cex=1.25, font=2)
  par(new=FALSE)
}