# snippets.R
#
# short examples of how to perform certain tasks

# We will rely on the following Hadley Wickham packages:
#
# * 'stringr' for consistent string functions
# * 'readr' for easy data ingest
# * 'lubridate' for powerful date functions

# ----- Station metadata ------------------------------------------------------

station <- readr::read_csv('2015_station_data.csv')
head(station)

# Convert date
station$online <- lubridate::mdy(station$online,tz="America/Los_Angeles")

# TODO:  add elevation and other data from Google with ggmap::revgeocode()
# TODO:  come up with other metrics of proximity to:  quiet streets, transit, work and play destinations
# TODO:  get recent cencus tract level data and use MazamaScienceUtils:: to get demographic data for each station
# TODO:  add columns with distance to other stations

# ----- Trip data -------------------------------------------------------------

trip <- readr::read_csv('2015_trip_data.csv')
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
trip$timeSinceStart <- difftime(trip$starttime,trip$starttime[1])
trip$daysInOperation <- as.numeric(trip$timeSinceStart,units="days")

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


