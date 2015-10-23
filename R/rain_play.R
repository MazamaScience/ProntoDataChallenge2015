# How much rain does it take to affect rider ship

load('data/Mazama_trip.RData')

# Create a time axis
startDate <- lubridate::floor_date(trip$startTime[1],'day')
stopDate <- lubridate::floor_date(trip$startTime[nrow(trip)],'day')
dates <- seq(startDate,stopDate,by='day')

# Count up all trips
allTrips <- table(trip$daysSinceStart)

# Count up trips with and without hard rain
trip$hardRain <- trip$precipIn > 0.25
hardRainTrips <- table(trip$daysSinceStart,trip$hardRain)

x <- as.numeric(allTrips)

a <- as.numeric(hardRainTrips[,1])
a[a == 0] <- NA
plot(x ~ dates, type='S',col='gray70')
points(a ~ dates, pch='-')
b <- as.numeric(hardRainTrips[,2])
b[b==0] <- NA
points(b ~ dates, pch='-', cex=2, col='blue')

