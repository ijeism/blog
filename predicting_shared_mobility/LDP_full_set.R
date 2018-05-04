library(readr)
library(plyr) # always load plyr before loading dplyr
library(dplyr)
library(tidyr)
library(geohash)

""" Read in Uber data """
uber <- read.csv('uber_6_14.csv')

summary(uber)
str(uber)
head(uber)

# Drop variable 'Base', not needed for further analysis
uber <- within(uber, rm(Base)) 

# Check for missing values and zeros
sum(is.na(uber$Date.Time))
sum(is.na(uber$Lat))
sum(is.na(uber$Lon))

sum(uber$Date.Time == 0)
sum(uber$Lat == 0)
sum(uber$Lon == 0)


# rename variables
uber.sample <- dplyr::rename(uber, start.time = Date.Time, start.long = Lon, start.lat = Lat) 

# create new variables
uber.sample$start.time <- strptime(uber.sample$start.time, format = '%m/%d/%Y %H:%M:%OS', tz = 'EST')
uber.sample <- tidyr::separate (uber.sample, start.time, c('date','time'), sep = ' ') # separate 'start.time' into several columns
uber.sample$wday <- weekdays(as.Date(uber.sample$date))

uber.sample <- tidyr::separate(uber.sample, time, c('hour','m','s'), sep = ':') # create new variable 'hour'
uber.sample <- select(uber.sample, -c(m,s))
uber.sample$wknd <- as.numeric(uber.sample$wday == 'Saturday' | uber.sample$wday == 'Sunday') # create dummy 'wknd' for weekend days
uber.sample$day <- format(as.Date(uber.sample$date, format = '%Y-%m-%d'), '%d') # create variable 'day'

# convert str into factor variables for 'hour', 'wday', and 'day'
uber.sample$hour <- as.factor(uber.sample$hour)
uber.sample$wday <- as.factor(uber.sample$wday)
uber.sample$day <- as.factor(uber.sample$day)

# add variable month
uber.sample$month <- 'June'

"""Read in Citi Bike data"""
bike <- read_csv('citi_bike_6_14.csv', col_types = "iccccnnccnnncic")

names(bike) <- make.names(names(bike)) # for convenience, rewrite names of columns to remove any spaces\

# rename variables
bike <- dplyr::rename(bike, start.time = starttime, start.lat = start.station.latitude, start.long = start.station.longitude) # rename variables

# subset df to retain only relevant variables
bike.sample <- select(bike, start.time, start.lat, start.long)

summary(bike.sample$start.time)
str(bike.sample$start.time)
head(bike.sample$start.time)

# any missing data?
sum(is.na(bike.sample$start.time))
sum(is.na(bike.sample$start.lat))
sum(is.na(bike.sample$start.long))

sum(bike.sample$start.time == 0)
sum(bike.sample$start.lat == 0)
sum(bike.sample$start.long == 0)

# Remove raw Citi Bike and Uber datasets to free workspace
rm("bike", "uber")

bike.sample$start.time <- strptime(bike.sample$start.time, format = '%Y-%m-%d %H:%M:%OS')

# create new variables
bike.sample <- tidyr::separate(bike.sample, start.time, c('date', 'time'), sep = ' ')
bike.sample$wday <- weekdays(as.Date(bike.sample$date))
bike.sample <- tidyr::separate(bike.sample, time, c('hour','m','s'), sep = ':')
bike.sample <- select(bike.sample, -c(m,s))
bike.sample$day <- format(as.Date(bike.sample$date, format = '%Y-%m-%d'), '%d')
bike.sample$wknd <- as.numeric(bike.sample$wday == 'Saturday' | bike.sample$wday == 'Sunday')

# add varibale month
bike.sample$month <- 'June'

"""Read in Green NYC Taxi trip data"""
green <- read_csv('green_taxi_6_14.csv', col_types = "cccccccccccccccccccc")

# Retain only relevant variables and rename accordingly
green.sample <- green %>% select(start.time = lpep_pickup_datetime, start.long = Pickup_longitude, start.lat = Pickup_latitude)

str(green.sample)
summary(green.sample)
head(green.sample)

# missing values and zeros
sum(is.na(green.sample$start.long))
sum(is.na(green.sample$start.lat))
sum(is.na(green.sample$start.time))

sum(green.sample$start.long == 0)
sum(green.sample$start.lat == 0)
sum(green.sample$start.time == 0)

green.sample <- filter(green.sample, start.long != 0 & start.lat != 0 & start.time != 0)

rm("green")

# create new variables
green.sample <- tidyr::separate(green.sample, start.time, c('date','time'), sep = ' ')
green.sample <- tidyr::separate(green.sample, time, c('hour','m','s'), sep = ':')
green.sample <- select(green.sample, -c(m,s))
green.sample$wday <- weekdays(as.Date(green.sample$date, format = '%Y-%m-%d'))
green.sample$day <- format(as.Date(green.sample$date, format = '%Y-%m-%d'), '%d')
green.sample$wknd <- as.numeric(green.sample$wday == 'Saturday' | green.sample$wday == 'Sunday')
green.sample$month <- 'June'

"""Read in Yellow NYC Taxi trip data"""
yellow <- read_csv('yellow_taxi_6_14.csv', col_types = "cccccccccccccccccccc")

# Retain only relevant variables and rename accordingly
yellow.sample <- select(yellow, start.time = pickup_datetime, start.long = pickup_longitude, start.lat = pickup_latitude)

# missing values
sum(is.na(yellow.sample$start.lat))
sum(is.na(yellow.sample$start.long))
sum(is.na(yellow.sample$start.time))

sum(yellow.sample$start.lat == 0)
sum(yellow.sample$start.long == 0)
sum(yellow.sample$start.time == 0)

# remove null values
yellow.sample <- filter(yellow.sample, start.lat != 0 | start.lat != 0 | start.time == 0)

rm("yellow")

str(yellow.sample)
summary(yellow.sample)
head(yellow.sample)


# create new variables
yellow.sample$hour <- format(strptime(yellow.sample$start.time, format = '%Y-%m-%d %H:%M:%S'), '%H')
yellow.sample$day <- format(strptime(yellow.sample$start.time, format = '%Y-%m-%d %H:%M:%S'), '%d')
yellow.sample <- tidyr::separate(yellow.sample, start.time, c('date', 'time'), sep = ' ')
yellow.sample$wday <- weekdays(as.Date(yellow.sample$date, format = '%Y-%m-%d'))
yellow.sample$wknd <- as.numeric(yellow.sample$wday == 'Saturday' | yellow.sample$wday == 'Sunday')
yellow.sample$month <- 'June'

"""Further transformations"""

# reorder colums of datasets to prepare for appending
uber.sample <- uber.sample[c('start.long', 'start.lat', 'date', 'hour', 'wday', 'day', 'wknd', 'month')]
bike.sample <- bike.sample[c('start.long', 'start.lat', 'date', 'hour', 'wday', 'day', 'wknd', 'month')]
green.sample <- green.sample[c('start.long', 'start.lat', 'date', 'hour', 'wday', 'day', 'wknd', 'month')]
yellow.sample <- yellow.sample[c('start.long', 'start.lat', 'date', 'hour', 'wday', 'day', 'wknd', 'month')]

# add variable 'type'
uber.sample$type <- "Uber"
bike.sample$type <- "City Bike"
green.sample$type <- "Green Cab"
yellow.sample$type <- "Yellow Cab"

# transform lat/long colums into numeric, then geohash to merge into single locations
# geohash each df before merging to get number of trips by type

uber.sample$start.long <- as.numeric(uber.sample$start.long)
uber.sample$start.lat <- as.numeric(uber.sample$start.lat)
uber.sample$geohash <- gh_encode(uber.sample$start.lat, uber.sample$start.long, 6)

bike.sample$start.long <- as.numeric(bike.sample$start.long)
bike.sample$start.lat <- as.numeric(bike.sample$start.lat)
bike.sample$geohash <- gh_encode(bike.sample$start.lat, bike.sample$start.long, 6)

green.sample$start.long <- as.numeric(green.sample$start.long)
green.sample$start.lat <- as.numeric(green.sample$start.lat)
green.sample$geohash <- gh_encode(green.sample$start.lat, green.sample$start.long, 6)

yellow.sample$start.long <- as.numeric(yellow.sample$start.long)
yellow.sample$start.lat <- as.numeric(yellow.sample$start.lat)
yellow.sample$geohash <- gh_encode(yellow.sample$start.lat, yellow.sample$start.long, 6)

# combine the four dataframes
total <- rbind(uber.sample, bike.sample, green.sample, yellow.sample)

# read in weather file
weather <- read.csv('weather.csv') 

# prepare df for merging with weather data
weather$day <- as.integer(weather$day)
total$day <- as.integer(total$day)

# merge with weather data, by day
mob.dem <- left_join(total, weather, by = c('month', 'day'))

# write df to csv
write.csv(mob.dem, file = "NYC_mobility_single")

head(mob.dem %>% group_by(type, geohash) %>% dplyr::summarize(n = n()) %>% arrange(desc(n)), 20)
nrow(mob.dem %>% group_by(type, geohash) %>% dplyr::summarize(n = n()))

# using precision of 5 yields 3,109 different geolocations
# when grouping mulitple variables, each summary peels off one level of the grouping, which makes it
# easy to progressively roll-up the dataset

hourly <- group_by(mob.dem, day, hour, type, geohash)
by_hour <- dplyr::summarise(hourly, n.total = n(), n.uber = sum(as.numeric(type == 'Uber')), n.bike = sum(as.numeric(type == 'City Bike')), n.green = sum(as.numeric(type == 'Green Cab')), n.yellow = sum(as.numeric(type == 'Yellow Cab'))) # 117,117 instances, once grouped by day, hour, and geohash
by_hour <- by_hour %>% group_by(day, hour, geohash) %>% summarize(n.total = sum(n.total), n.uber = sum(n.uber), n.bike = sum(n.bike), n.green = sum(n.green), n.yellow = sum(n.yellow))
head(arrange(by_hour, desc(n.total)), 10)

# decode hashes and append columns to dataset by_hour
loc <- gh_decode(by_hour$geohash)
by_hour$lat <- loc$lat
by_hour$long <- loc$lng

# extract distinct days from mob.dem, subset to keep only relevant variables
# and merge with by_hour dataset
unique <- mob.dem[!duplicated(mob.dem[,'day']),]
unique <- unique %>% select(day, wday, wknd, month, mean_temp, precip_sum) %>% arrange(day)
by_hour <- left_join(by_hour, unique, by = 'day')

# write df to csv
write.csv(by_hour, file = "NYC_trip_density_June_6")


