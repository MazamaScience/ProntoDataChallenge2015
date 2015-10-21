# snippets.R
#
# short examples of how to perform certain tasks

# We will rely on the following Hadley Wickham packages:
#
# * 'stringr' for consistent string functions
# * 'readr' for easy data ingest
# * 'lubridate' for powerful date functions

# Load the improved station metadata
load('data/Mazama_station.RData')

# ----- Trip data -------------------------------------------------------------

trip <- readr::read_csv('data/2015_trip_data.csv')
head(trip)

# Convert starttime
trip$starttime <- lubridate::mdy_hm(trip$starttime,tz="America/Los_Angeles")
# Simplify/add other columns
trip$duration <- as.integer(trip$tripduration)
trip$age <- 2015 - trip$birthyear
trip$bikeid <- stringr::str_replace(trip$bikeid,'SEA','')
# Create factors
trip$from_station_name <- as.factor(trip$from_station_name)
trip$to_station_name <- as.factor(trip$to_station_name)
trip$usertype <- as.factor(trip$usertype)
trip$gender <- as.factor(trip$gender)
# New columns
trip$hourOfDay <- lubridate::hour(trip$starttime)
trip$dayOfWeek <- lubridate::wday(trip$starttime)
trip$weekday <- trip$dayOfWeek <= 5
trip$weekend <- trip$dayOfWeek > 5
trip$timeSinceStart <- difftime(trip$starttime,trip$starttime[1])
trip$daysInOperation <- as.numeric(trip$timeSinceStart,units="days")

# Add elevation difference
rownames(station) <- station$terminal
# NOTE:  Access by rownames requires matrix notation
trip$elevationDiff <- station[trip$to_station_id,'elevation'] - station[trip$from_station_id,'elevation']

# TODO:  Use lubridate functions to add weekend/weekday and other
# TODO:  Use maptools::sunriset() and and maptools::crepescule() to add daylight information
# TODO:    [need to create spatial coords from seattle longitude/latitude]
# TODO:  Add columns:  elevation change, weather, distance, ...

# ----- Data exploration ------------------------------------------------------

# TODO:  Recode these using dplyr and ggplot?

oldPar <- par()

# Simple exploratory plots
pie(table(trip$gender))
hist(trip$duration[trip$duration < 3600],n=50)
hist(trip$age,n=50)

# Resource usage
barplot(sort(table(trip$bikeid)))
par(mar=c(5,30,4,2)+.1)
barplot(sort(table(trip$from_station_name)),horiz=TRUE, las=1)
barplot(sort(table(trip$to_station_name)),horiz=TRUE, las=1)
par(oldPar)
# Interesting subsets
femaleShortTrips <- subset(trip, duration<1200 & gender=='Female')
maleShortTrips <- subset(trip, duration<1200 & gender=='Male')

# Men vs. Women
adjustedAge <- maleShortTrips$age+0.5
# NOTE:  pch=15 because squares are faster to draw than circles
# NOTE:  different opacity to adjust for the different number of men and women
plot(maleShortTrips$duration ~ adjustedAge, pch=15, col=adjustcolor('royalblue',.02))
points(femaleShortTrips$duration ~ femaleShortTrips$age, pch=15, col=adjustcolor('salmon',.03))

# ----- Various subsets -------------------------------------------------------

# Top from stations
trip %>% ###filter(weekend) %>%
  group_by(from_station_id) %>%
  summarize(count=n()) %>%
  arrange(desc(count)) ->
  from_stations

# Top weekend to stations
trip %>% ###filter(weekend) %>%
  group_by(to_station_id) %>%
  summarize(count=n()) %>%
  arrange(desc(count)) ->
  to_stations

# All combinations of from-to stations
trip %>% filter(from_station_id == to_station_id) %>%
  group_by(from_station_id) %>%
  summarize(count=n()) %>%
  arrange(desc(count)) ->
  self_stations

# All combinations of from-to stations
trip %>% filter(from_station_id != to_station_id) %>%
  group_by(from_station_id) %>%
  summarize(count=n()) %>%
  arrange(desc(count)) ->
  non_self_stations

non_self <- dplyr::filter(trip, from_station_id != to_station_id)
hist(non_self$elevationDiff,breaks=seq(-150,150,2))
plot(non_self$elevationDiff ~ non_self$hourOfDay, pch=15, col=adjustcolor('black',0.01))
abline(h=0,lwd=4,col=adjustcolor('salmon',0.5))
plot(non_self$elevationDiff ~ non_self$age, pch=15, col=adjustcolor('black',0.01))
abline(h=0,lwd=4,col=adjustcolor('salmon',0.5))


# ---- Subset for d3 chord diagram --------------------------------------------

trip$from_area_id <- stringr::str_replace(trip$from_station_id,'-.*$','')
trip$to_area_id <- stringr::str_replace(trip$to_station_id,'-.*$','')

# All combinations of from-to stations
trip %>% filter(from_area_id != to_area_id) %>%
  filter(from_area_id != 'Pronto shop') %>%
  filter(to_area_id != 'Pronto shop') %>%
  group_by(from_area_id,to_area_id) %>%
  summarize(count=n()) ->
  from_to_areas

# Create a dataframe for a heatmap
melted <- reshape2::melt(from_to_areas, measure.vars='count')
from_to_df <- reshape2::dcast(melted, from_area_id ~ to_area_id)
from_to_df[is.na(from_to_df)] <- 0
from_to_matrix <- as.matrix(from_to_df[,-1])
labRow <- from_to_df[,1]
labCol <- colnames(from_to_df)[-1]

# Can use the heatmap chunk below to display this

readr::write_csv(from_to_df,'area_connections.csv')

# ----- Some new ideas on station interconnectedness --------------------------

# All combinations of from-to stations
trip %>% filter(weekend) %>%
  group_by(from_station_id,to_station_id) %>%
  summarize(count=n()) %>%
  arrange(desc(count)) ->
  from_to_stations

# All combinations of from-to stations
#trip %>% filter(usertype == 'Short-Term Pass Holder') %>%
#trip %>% filter(usertype == 'Annual Member') %>%
#trip %>% filter(gender == 'Female') %>%
#trip %>% filter(daysInOperation > 200) %>%
#trip %>% filter(hourOfDay > 4) %>%
trip %>% filter(gender == 'Male' & birthyear == 1963) %>%
  #filter(usertype == 'Annual Member') %>%
  group_by(from_station_id,to_station_id) %>%
  summarize(count=n()) ->
  from_to_stations

# Create a dataframe for a heatmap
melted <- reshape2::melt(from_to_stations, measure.vars='count')
from_to_df <- reshape2::dcast(melted, from_station_id ~ to_station_id)
from_to_df[is.na(from_to_df)] <- 0
from_to_matrix <- as.matrix(from_to_df[,-1])
labRow <- from_to_df[,1]
labCol <- colnames(from_to_df)[-1]

# Add colors for the most important stations
NUM_CATEGORIES <- 5
fromCount <- rowSums(from_to_matrix)
fromCodes <- .bincode(fromCount,
                      breaks=quantile(fromCount, probs=seq(0,1,length.out=NUM_CATEGORIES+1)),
                      include.lowest=TRUE)
fromColors <- rev(heat.colors(NUM_CATEGORIES))[fromCodes]

toCount <- colSums(from_to_matrix)
toCodes <- .bincode(toCount,
                    breaks=quantile(toCount, probs=seq(0,1,length.out=NUM_CATEGORIES+1)),
                    include.lowest=TRUE)
toColors <- rev(heat.colors(NUM_CATEGORIES))[toCodes]

heatmap(as.matrix(from_to_matrix),col=rev(heat.colors(12)),
        margins=c(6,6),
        xlab='To Station', ylab='From Station',
        #Rowv=NA, Colv=NA, # to remove reordering for culstering
        ColSideColors=toColors, # NOTE:  Total trips
        RowSideColors=fromColors, # NOTE:  Total trips
        labRow=labRow, labCol=labCol)
