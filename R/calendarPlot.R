# calendarPlot.R
#
#
# Uses thepackage

# TODO:  Consider using d3 version:
#
# http://www.qlikblog.at/3070/calendar-heatmap-qlikview-extension-d3calendarview/

load('data/Mazama_trip.RData')

# Count up trips
tripsPerDay <- as.numeric(table(trip$daysSinceStart))

# Create a time axis
startDate <- lubridate::floor_date(trip$startTime[1],'day')
stopDate <- lubridate::floor_date(trip$startTime[nrow(trip)],'day')
dates <- seq(startDate,stopDate,by='day')

# # From http://stackoverflow.com/questions/27000131/calendar-heat-map-tetris-chart
# 
# stock <- "MSFT"
# quote <- sprintf("http://ichart.finance.yahoo.com/table.csv?s=%s&g=d&ignore=.csv", stock)
# 
# # stock.data <- read.csv(quote, as.is=TRUE) %>% tbl_df %>% 
# #   mutate(date=as.Date(Date, format='%Y-%m-%d')) %>% 
# #   filter(date >= '2006-02-13' & date <= '2009-10-30')
# 
# stock.data <- data.frame()
# 
# calendar_tetris_geoms <- function() {
#   list(
#     geom_segment(aes(x=x, xend=x, y=ymin, yend=ymax)),                 # (a)
#     geom_segment(aes(x=xmin, xend=xmax, y=y, yend=y)),                 # (b)
#     geom_segment(aes(x=dec.x, xend=dec.x, y=dec.ymin, yend=dec.ymax)), # (c)
#     geom_segment(aes(x=nye.xmin, xend=nye.xmax, y=nye.y, yend=nye.y)), # (d)
#     geom_segment(x=-0.5, xend=51.5, y=7.5, yend=7.5),                  # put a line along the top
#     geom_segment(x=0.5, xend=52.5, y=0.5, yend=0.5),                   # put a line along the bottom
#     geom_text(aes(x=month.x, y=month.y, label=month.l), hjust=0.25)    # (e)
#   )
# }
# 
# #calendar_tetris_data(min(stock.data$date), max(stock.data$date)) %>% 
# #  left_join(stock.data) %>% 
# calendar_tetris_data(min(stock.data$date), max(stock.data$date)) %>% 
#   left_join(stock.data) %>% 
#   ggplot() + 
#   geom_tile(aes(x=week, y=wday2factor(wday), fill = Adj.Close), colour = "white") + 
#   calendar_tetris_geoms() + 
#   facet_wrap(~ year, ncol = 1)



#################################################
# From https://gist.github.com/dvmlls/5f46ad010bea890aaf17
#################################################

library(ggplot2)
library(dplyr)

# http://stackoverflow.com/a/2078411/908042

stock <- "MSFT"
quote <- sprintf("http://ichart.finance.yahoo.com/table.csv?s=%s&g=d&ignore=.csv", stock)

stock.data <- read.csv(quote, as.is=TRUE) %>% tbl_df %>% 
  mutate(date=as.Date(Date, format='%Y-%m-%d')) %>% 
  filter(date >= '2006-02-13' & date <= '2009-10-30')

year <- function(d) as.integer(format(d, '%Y'))

wday <- function(d) {
  n <- as.integer(format(d, '%u'))
  ifelse(n==7, 0, n) + 1 # I want the week to start on Sunday=1, so turn 7 into 0.
}

wday2factor <- function(wd) factor(wd, levels=1:7, labels=c('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'))

week <- function(d, year) { 
  # If January 1st is a Sunday, my weeks will start from 1 instead of 0 like the rest of them. 
  nyd <- as.Date(ISOdate(year, 1, 1))
  # So if that's the case, subtract 1. 
  as.integer(format(d, '%U')) - ifelse(wday(nyd) == 1, 1, 0)
}

calendar_tetris_data <- function(date_min, date_max) {
  
  start <- as.Date(ISOdate(year(min(date_min)),1,1))
  end <- as.Date(ISOdate(year(max(date_max)), 12, 31))
  
  all.dates <- start + 0:as.integer(end - start, units='days')
  
  data.frame(date=all.dates) %>% tbl_df %>% 
    mutate(
      wday=wday(date),
      year=year(date),
      month=as.integer(format(date, '%m')),
      week=week(date, year),
      day=as.integer(format(date, '%d')),
      # (a) put vertical lines to the left of the first week of each month
      x=ifelse(day <= 7, week - 0.5, NA),
      ymin=ifelse(day <= 7, wday - 0.5, NA),
      ymax=ifelse(day <= 7, wday + 0.5, NA),
      # (b) put a horizontal line at the bottom of the first of each month
      y=ifelse(day == 1, wday - 0.5, NA),
      xmin=ifelse(day == 1, week - 0.5, NA),
      xmax=ifelse(day == 1, week + 0.5, NA),
      # (c) in december, put vertical lines to the right of the last week
      dec.x=ifelse(month==12 & day >= 25, week + 0.5, NA),
      dec.ymin=ifelse(month==12 & day >= 25, wday - 0.5, NA),
      dec.ymax=ifelse(month==12 & day >= 25, wday + 0.5, NA),
      # (d) put a horizontal line at the top of New Years Eve
      nye.y=ifelse(month==12 & day == 31, wday + 0.5, NA),
      nye.xmin=ifelse(month==12 & day == 31, week - 0.5, NA),
      nye.xmax=ifelse(month==12 & day == 31, week + 0.5, NA),
      # (e) put the first letter of the month on the first day
      month.x=ifelse(day == 1, week, NA),
      month.y=ifelse(day == 1, wday, NA),
      month.l=ifelse(day == 1, substr(format(date, '%B'), 1, 3), NA)
    )
}

# FAKE STOCK DATA
# stock.data <- data.frame(Adj.Close=as.numeric(tripsPerDay),
#                          date=as.Date(dates))

load('data/Mazama_weather.RData')

stock.data <- data.frame(Adj.Close=weather$Precipitation_In,
                         date=as.Date(dates))

# TODO:  Show the connection between rain and ridership. Rain > 0.5 totally kills ridership

calendar_tetris_data(min(stock.data$date), max(stock.data$date)) %>% left_join(stock.data) %>% 
  ggplot() + 
  geom_tile(aes(x=week, y=wday2factor(wday), fill = Adj.Close), colour = "white") + 
  #scale_fill_gradientn(colours = rev(c("#D61818","#FFAE63","#FFFFBD","#B5E384")), na.value='transparent') +
  scale_fill_gradientn(colours = c("antiquewhite","antiquewhite3","orange","red","firebrick"), na.value='transparent') +
  ###geom_tile(aes(x=week, y=wday2factor(wday), fill = factor(Adj.Close)), colour = "white") + 
  ###scale_fill_discrete(breaks = c("0","500","1000","1500"), palette=colorRampPalette(c('white','orange','red')), na.value='transparent') +
  geom_segment(aes(x=x, xend=x, y=ymin, yend=ymax)) +                       # (a)
  geom_segment(aes(x=xmin, xend=xmax, y=y, yend=y)) +                       # (b)
  geom_segment(aes(x=dec.x, xend=dec.x, y=dec.ymin, yend=dec.ymax)) +       # (c)
  geom_segment(aes(x=nye.xmin, xend=nye.xmax, y=nye.y, yend=nye.y)) +       # (d)
  geom_segment(x=-0.5, xend=51.5, y=7.5, yend=7.5) +                        # put a line along the top
  geom_segment(x=0.5, xend=52.5, y=0.5, yend=0.5) +                         # put a line along the bottom
  geom_text(aes(x=month.x, y=month.y, label=month.l), hjust=0.25) +         # (e)
  scale_x_continuous(expand=c(0.01,0.01)) +                                 # remove excessive left+right padding 
  theme(axis.title.y=element_blank(), axis.title.x=element_blank(),         # remove axis titles
        panel.grid.major=element_blank(), panel.grid.minor=element_blank(), # remove gridlines 
        legend.title=element_blank(),                                       # remove legend title
        axis.text.x=element_blank(), axis.ticks.x=element_blank()           # remove x-axis labels and ticks
  ) + 
  facet_wrap(~ year, ncol = 1) 
