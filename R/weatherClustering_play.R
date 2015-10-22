# Do we have any identifiable types of weather?

# Should do similar analysis with the weater parameters in the trip dataframe

load('data/Mazama_weather.RData')

# > names(weather)
#  [1] "Date"                       "Max_Temperature_F"          "Mean_Temperature_F"        
#  [4] "Min_Temperature_F"          "Max_Dew_Point_F"            "MeanDew_Point_F"           
#  [7] "Min_Dewpoint_F"             "Max_Humidity"               "Mean_Humidity"             
# [10] "Min_Humidity"               "Max_Sea_Level_Pressure_In"  "Mean_Sea_Level_Pressure_In"
# [13] "Min_Sea_Level_Pressure_In"  "Max_Visibility_Miles"       "Mean_Visibility_Miles"     
# [16] "Min_Visibility_Miles"       "Max_Wind_Speed_MPH"         "Mean_Wind_Speed_MPH"       
# [19] "Max_Gust_Speed_MPH"         "Precipitation_In"           "Events"                    
# [22] "rain"                       "fog"                        "snow"                      
# [25] "thunderstorm"               "timeSinceStart"             "daysSinceStart"            

# Get rid of Date, Events and the ~sinceStart columns
weather <- weather[,-c(1,21,26,27)]

# ----- Can we cluster based on temps, humidity, wind and precip?

sub <- weather[,c(2,4,9,18,20)]

# > names(sub)
#  [1] "Max_Temperature_F"   "Min_Temperature_F"   "Mean_Humidity"       "Mean_Wind_Speed_MPH"
#  [5] "Precipitation_In"   

plot(sub)
title("No compelling clusters")

# Find out how many clusters kmeans thinks is appropriate
clusterCount <- 1:10
tot.withinss <- unlist( lapply(clusterCount, function(x) { kmeans(sub,x)$tot.withinss } ) )
names(tot.withinss) <- clusterCount
barplot(tot.withinss)
title('Looks like 4 clusters is probably the best.')

plot(sub,col=kmeans(sub,2)$cluster) # Nothing compelling
plot(sub,col=kmeans(sub,3)$cluster) # Separates temp and humidity
plot(sub,col=kmeans(sub,4)$cluster) # BEST
plot(sub,col=kmeans(sub,5)$cluster) # Too many classes?

# ----- Can we cluster based on event masks ?

sub <- weather[,c(22:25)]
plot(sub)
title('Yes we can cluster based on logical masks. But it\'s not meaningful')

clusterCount <- 1:10
tot.withinss <- unlist( lapply(clusterCount, function(x) { kmeans(sub,x)$tot.withinss } ) )
names(tot.withinss) <- clusterCount
barplot(tot.withinss)
title('Looks like 4 clusters is probably the best.')

# ----- Let's use some weather knowledge to get high pressure days

sub <- weather[,c(2,4,11,15)]
plot(sub)
title('Nothing to see here')

# ----- Random guess? (Repeat ad nauseam)

randomClusters <- function(n,k) {
  columns <- sample(1:23,n)
  sub <- weather[,columns]
  names(sub)

  clusterCount <- 1:10
  tot.withinss <- unlist( lapply(clusterCount, function(x) { kmeans(sub,x)$tot.withinss } ) )
  names(tot.withinss) <- clusterCount
  barplot(tot.withinss)
  
  plot(sub,col=kmeans(sub,k)$cluster)
}


# Interesing!!! The following parameters break things into categories

# ----- Sweat Factor?

sub <- weather[,c(1,6,7)]
plot(sub,col=kmeans(sub,4)$cluster)
title('Sweat Factor is OK at partitioning -- (Nice! temp up = humidity down)')

# ----- Nasty weather?

sub <- weather[,c(3,17,19)]
plot(sub,col=kmeans(sub,3)$cluster)
title("Nasty weather factor -- wind speed isn't important")

# ---- Best factors so far

sub <- weather[,c(1,3,6,7,19)]
plot(sub,col=kmeans(sub,2)$cluster)


# -----------------------------------------------------------

load('data/Mazama_trip.RData')
sub <- trip[,c(19:25)]
#plot(sub,col=adjustcolor(kmeans(sub,2)$cluster,.01),pch=15) # Slow and nothing evident
sub <- trip[,c(21,24)]
plot(sub[,1] ~ sub[,2], col=kmeans(sub,2)$cluster, pch=15) # Nothing here

# Does rain affect when people start?
barplot(table(trip[,c('rain','hourOfDay')]),beside=TRUE)