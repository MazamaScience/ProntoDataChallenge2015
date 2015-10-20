# Exploring Pronto Data
library(readr)
library(lubridate)



station <- read_csv("/Users/rubyfore/Projects/ProntoDataChallenge2015/data/2015_station_data.csv")

tripData <- read_csv('/Users/rubyfore/Projects/ProntoDataChallenge2015/data/2015_trip_data.csv')

tripData$starttime <- mdy_hm(tripData$starttime, tz="America/Los_Angeles")
tripData