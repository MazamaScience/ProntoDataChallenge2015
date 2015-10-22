# createWeatherDF.R
#
# This script reads in the weather data .csv file and improves it in the 
# following ways:
#
# * changes column names to adhere to MazamaScience standards
# * changes column types
# * adds additional metadata columns
#
# We will rely on the following (largely Hadley Wickham) R packages:
#
# * lubridate  - powerful date functions
# * readr      - easy data ingest

# ----- BEGIN -----------------------------------------------------------------

# Read in, assign names and types
weather <- readr::read_csv('data/2015_weather_data.csv')

# > names(weather)
#  [1] "Date"                        "Max_Temperature_F"           "Mean_Temperature_F"         
#  [4] "Min_TemperatureF"            "Max_Dew_Point_F"             "MeanDew_Point_F"            
#  [7] "Min_Dewpoint_F"              "Max_Humidity"                "Mean_Humidity "             
# [10] "Min_Humidity "               "Max_Sea_Level_Pressure_In "  "Mean_Sea_Level_Pressure_In "
# [13] "Min_Sea_Level_Pressure_In "  "Max_Visibility_Miles "       "Mean_Visibility_Miles "     
# [16] "Min_Visibility_Miles "       "Max_Wind_Speed_MPH "         "Mean_Wind_Speed_MPH "       
# [19] "Max_Gust_Speed_MPH"          "Precipitation_In "           "Events"                     

# NOTE:  Several problems need to be fixed with this dataset:
# NOTE:  1) several names have an extra space at the end
# NOTE:  2) the Max_Wind_Speed_MPH column has a "-" which makes everything character
# NOTE:  3) the Events column has weather names types but somtimes more than one with a comma

# > unique(weather$Events)
# [1] "Rain"                ""                    "Rain , Snow"         "Fog"                
# [5] "Fog , Rain"          "Rain , Thunderstorm"

# Fix names
names(weather) <- stringr::str_replace(names(weather),' ','')

# Fix Max_Gust_Speed_MPH
weather$Max_Gust_Speed_MPH <- ifelse(weather$Max_Gust_Speed_MPH=='-',weather$Max_Wind_Speed_MPH,weather$Max_Gust_Speed_MPH)
weather$Max_Gust_Speed_MPH <- as.numeric(weather$Max_Gust_Speed_MPH)

# Create additional columns from Events
weather$rain <- stringr::str_detect(weather$Events,'Rain')
weather$fog <- stringr::str_detect(weather$Events,'Fog')
weather$snow <- stringr::str_detect(weather$Events,'Snow')
weather$thunderstorm <- stringr::str_detect(weather$Events,'Thunderstorm')

# Convert dates and times to POSIXct using lubridate
weather$Date <- lubridate::mdy(weather$Date, tz='America/Los_Angeles')
weather$timeSinceStart <- difftime(weather$Date,weather$Date[1])
weather$daysSinceStart <- as.integer(as.numeric(weather$timeSinceStart,units="days"))


# ----- Save the dataframe ----------------------------------------------------

save(station,file='data/Mazama_weather.RData')

readr::write_csv(station,path='data/Mazama_weather.csv')

# ----- END -------------------------------------------------------------------

