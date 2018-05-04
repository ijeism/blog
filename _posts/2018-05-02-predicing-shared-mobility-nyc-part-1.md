---
published: true
layout: post
categories: machine learning; EDA
author: I ON
meta: Springfield
---
![]({{site.baseurl}}/assets/shared_mob.png)


## Introduction

People need to move around to secure basic human needs. Mobility is more than a luxury - it contributes to the quality of life by enabling exploration, leisure and recreation. Well thought-out mobility solutions attract businesses and lead to the creation of jobs; as such they are necessary for any city to thrive. Mobility is therefore a key dynamic of urbanization and is widely cited as one of the most intractable, universal challenges faced by cities all over the world. (Arup & Schneider Electric, 2014).

For interested parties, such as taxi companies, urban mobility planners, entrepreneurs, or public transit authorities to be able to make smart decisions in providing improved mobility solutions, they require accurate information about the distribution of demand for shared mobility across space and time. In addition, they need to be able to predict the number of people that want to move from one location to another using some means of shared transportation, given a time, day, and location.

The proposal for this project was therefore to develop a data driven application that will enable all these parties to evaluate the demand for shared mobility for a given location, date and time to enable them make informed decisions. In a 2-part series, I'll go through the analytics bit behind the proposed solution. This post looks at data pre-processing.

# Project Workflow
The general framework for this machine learning project is as follows:

1. Data integration and cleaning
2. Feature engineering
3. Exploratory data analysis
4. Modelling and model assessment
5. Prediction



# 1. Data integration and pre-processing
Data for the three categories bike-sharing; ride-sourcing; and taxis & limos was used to gauge demand for shared mobility. I select three months’ worth of data, spanning the period of April 2014 - June 2014.

Datasets:
-	NYC yellow taxi dataset: [http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml](http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml)
-	NYC green taxi dataset: [http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml](http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml)
-	Uber dataset: [https://github.com/fivethirtyeight/uber-tlc-foil-response/tree/master/uber-trip-data](https://github.com/fivethirtyeight/uber-tlc-foil-response/tree/master/uber-trip-data)
-	Citi bike dataset: [https://s3.amazonaws.com/tripdata/index.html](https://s3.amazonaws.com/tripdata/index.html)
-	Weather: [https://www.wunderground.com/history/](https://www.wunderground.com/history/)

Using R, we merge the Yellow Taxi, Green Taxi, Uber, Citi Bike datasets, including only variables they have in common, restricting us to DateTime, Latitude, and Longitude for each trip started (as these are the only variables available in the Uber dataset). 

I then create a new categorical variable, with factors corresponding to ride type, i.e. yellow cab, green cab, Uber, or Citi Bike. Next I merge the weather data, consisting of average temperature (Celsius) and total precipitation (mm) on the day, by date, i.e. I assign the appropriate temperature and total precipitation to each individual trip according to its reported date.
 
In order to restrict our analysis to New York City, I subset the dataset to include only trips that started within the city, using a reverse geocoding system. 

I also exclude any instances where either latitude or longitude take on a value of zero or have a missing value, as these are the two of the three variables required to make an instance useful for our analysis. 


# 2. Feature engineering
In order to extract more information out of our dataset, I create new variables using R. Specifically, I split the *DateTime* variable, resulting in three additional features *month* (three factors), *day* (30 or 31 factors, depending on the month), and *hour* (24 factors). I also create a variable *wday* (7 levels) to identify what day of the week each trip took place, as well as a variable binary *wknd* that takes the value 1 if the trip took place on either a Saturday or a Sunday, and 0 otherwise. 

Next, I make use of the **geohash system** , which is a way to encode latitude and longitude into groups of nearby points on the globe with varying resolutions (Whelan, 2011). This allows me to then group together trips that were started (relatively) close by to obtain a number of trips taken at that approximate location at a particular time, *n.total*; this process also reduces the dimensionality of the dataset.  

Using a **reverse geocoding system**, I generate information about the location name/zip code associated with each longitude/latitude pair, resulting in additional variables borough and community district. Unfortunately, the library does not convert all our longitude / latitude combinations, leaving me with a number of trips, which we know are assigned within the bounds of NYC, but cannot link to any sub-locations. 

Additionally, in order to be able to differentiate between types of trips taken, I break down the total number of trips by location and create four further variables *n.yellow*, *n.green*, *n.uber*, and *n.bike* that take on the number of trips taken in a location by yellow cab, green cab, Uber, and Citi Bike, respectively. 

Note that I am also using **circular variables** i.e. day of the month, day of the week, and hour of the day. These are variables that indicate cyclical time and are characterized by the fact that the beginning and the end of their scales meet. Most familiar statistics don’t work well with circular variables since they assume linearity, i.e. the lowest value being farthest from the highest value. For example, hours of a day, split into 24 bins (0 - 23), represent the daily cycle; 0, in this case, is much closer to 22 than to, say, 5. I tackle this issue by using cosine and sine functions to place our circular variables into a standardized Cartesian space. This essentially makes it easier for the model to find relevant patterns (The Analysis Factor, n.d.). This creates 6 new variables: *hour.num*, *hour.cos*, *hour.sin*, *wday.num*, *wday.cos*, *wday.sin*.

Table 1 shows the metadata of our final dataset for analysis:

Variable Code|Description|Level
------|-------|-------
month|Month| Categorical
day|Day of the month| Categorical
hour|Hour of the day| Categorical
hour.num|2*pi*(hour + 0.5)/24|Numeric
hour.cos|cos(hour.num)|Numeric
hour.sin|sin(hour.num)|Numeric
n.total|Total number of trips taken|Numeric
n.uber|Number of Uber trips taken|Numeric
n.bike|Number of Citi Bike trips taken|Numeric
n.green|Number of Green Taxi trips taken|Numeric
n.yellow|Number of Yellow Taxi trips taken|Numeric
lat|Latitude of location|Numeric
lon|Longitude of location|Numeric
wday|Weekday|Categorical
wday.num|2*pi*wday/7|Numeric
wday.cos|cos(wday.num)|Numeric
wday.sin|sin(wday.num)|Numeric
wknd|Weekend|Binary
mean_temp|Average temperature by day|Numeric
precip_sum|Total daily precipitation by day|Numeric

*Table 1 Metadata table*


# 3. Exploratory Data Analysis 

# 3.1 Cyclical trends of demand

Figure 1 depicts the cyclical trend of pickups throughout a week. Taxi, Uber, and Bike follow a similar cyclical trend in the sense that activity is high on weekdays and comparatively low on weekends. Activity for both taxi and Uber seems to peak on Wednesdays, while bike activity remains relatively stable across weekdays. On weekends, bike demand seems higher on Sundays, while Sundays show the lowest pickup activity for Taxi and Uber. Notice also how activity for Uber and Taxi tends to be highest on days with low temperatures, while this observation is not as clear from the bike graph.
 

![Picture1.png]({{site.baseurl}}/assets/Picture1.png)
 
Figure 1 Demand by weekday

Figure 2 shows that on working days (first row), peak activity typically occurs during the morning hours (around 8am) and right after close of business (around 5pm), with somewhat increased activity also around lunchtime. This is the case across each type of transportation, although there are differences in the distribution of pickup activity throughout the day. 

Notice, again, that maximum pickup counts for Taxi and Uber seem to be highest when mean temperatures are lowest, while pickup activity on days with lower temperature tends to be lower for the Bike. This makes sense, since bike users are more exposed to weather conditions than car users.

On the other hand, pickup activity on non-working days (second row) follow a different pattern. Pickups for Taxi and Uber in particular are high during the very early morning hours (perhaps when people return home from a night out) and have another peak in the afternoon hours, with a slightly different distribution. Again, highest count tends to occur on days with low mean temperatures. Bike activity also shows a steady rise and fall during the afternoon hours, although to a much lesser extent on cooler days; somewhat increased activity equally occurs during early morning hours (from around midnight till 3-4 am).


![Picture1.png]({{site.baseurl}}/assets/Picture2.png)

Figure 2 Demand by hour (weekday vs. weekend)


# 3.2 Location

Figure 3 clearly shows a strong relationship between location and number of pickups. Pickup activity is focused on particular areas within NYC, which is reflected by higher counts (larger point sizes on the scatterplot) at certain lat/long intersections. Comparing the graphs for Taxi, Uber, and Bike, we can make out only subtle differences between the operation areas of the three transportation types (not depicted here). Overall there is a significant focus on the Manhattan area.

![Picture1.png]({{site.baseurl}}/assets/Picture3.png) 

Figure 3 Demand by location (Latitude vs. Longitude, by number of pickups)

# 3.3 Precipitation

Figure 4 illustrates the relationship between pickups and amount of rainfall and clearly shows how Bike pickups decrease with increasing precipitation. Uber pickups, on the other hand, seem to increase with precipitation while Taxi activity tends to drop with increased rainfall. 

![Picture1.png]({{site.baseurl}}/assets/Picture4.png) 

Figure 4 Demand by rainfall (number of pickups vs. precipitation, by mean temperature)

Full code can be found [here](https://github.com/ijeism/ijeism.github.io/tree/master/predicting_shared_mobility). Hop over to [Part 2](https://ijeism.github.io/blog/machine/learning;/eda/2018/05/02/predicting-shared-mobility-nyc-part-2.html) to see how I applied machine learning algorithms to predict demand for shared mobility services.
