---
published: true
layout: post
categories: machine learning; EDA
author: I ON
meta: Springfield
---
# Predicting Shared Mobility Patterns in New York City - Data Preprocessing

People need to move around to secure basic human needs. Mobility is more than a luxury - it contributes to the quality of life by enabling exploration, leisure and recreation. Well thought-out mobility solutions attract businesses and lead to the creation of jobs; as such they are necessary for any city to thrive. Mobility is therefore a key dynamic of urbanization and is widely cited as one of the most intractable, universal challenges faced by cities all over the world. (Arup & Schneider Electric, 2014).

For interested parties, such as taxi companies, urban mobility planners, entrepreneurs, or public transit authorities to be able to make smart decisions in providing improved mobility solutions, they require accurate information about the distribution of demand for shared mobility across space and time. In addition, they need to be able to predict the number of people that want to move from one location to another using some means of shared transportation, given a time, day, and location.

Inspired by (Gong et al., 2016), the proposal for this project was therefore to develop a data driven application that will enable all these parties to evaluate the demand for shared mobility for a given location, date and time to enable them make informed decisions. In a 3-part series, we'll go through the analytics bit of the proposed solution.


## Data integration and pre-processing
We use data on the three categories bike-sharing; ride-sourcing; and taxis & limos to gauge demand for shared mobility. We select three months’ worth of data, spanning the period of April 2014 - June 2014.

Datasets:
-	NYC yellow taxi dataset: [http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml](http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml)
-	NYC green taxi dataset: [http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml](http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml)
-	Uber dataset: [https://github.com/fivethirtyeight/uber-tlc-foil-response/tree/master/uber-trip-data](https://github.com/fivethirtyeight/uber-tlc-foil-response/tree/master/uber-trip-data)
-	Citi bike dataset: [https://s3.amazonaws.com/tripdata/index.html](https://s3.amazonaws.com/tripdata/index.html)
-	Weather: [https://www.wunderground.com/history/](https://www.wunderground.com/history/)

Using R, we merge the Yellow Taxi, Green Taxi, Uber, Citi Bike datasets, including only variables they have in common, restricting us to DateTime, Latitude, and Longitude for each trip started (as these are the only variables available in the Uber dataset). 

We then create a new categorical variable, with factors corresponding to ride type, i.e. yellow cab, green cab, Uber, or Citi Bike. Next we merge the weather data, consisting of average temperature (Celsius) and total precipitation (mm) on the day, by date, i.e. we assign the appropriate temperature and total precipitation to each individual trip according to its reported date.


## Data cleaning 
In order to restrict our analysis to New York City, we subset the dataset to include only trips that started within the city, using a reverse geocoding system. 

We also exclude any instances where either latitude or longitude take on a value of zero or have a missing value, as these are the two of the three variables required to make an instance useful for our analysis. 


## Feature engineering
In order to extract more information out of our dataset, we create new variables using R. Specifically, we split the DateTime variable, resulting in three additional features month (three factors), day (30 or 31 factors, depending on the month), and hour (24 factors). We also create a variable wday (7 levels) to identify what day of the week each trip took place, as well as a variable binary wknd that takes the value 1 if the trip took place on either a Saturday or a Sunday, and 0 otherwise. 

Next, we make use of the **geohash system** , which is a way to encode latitude and longitude into groups of nearby points on the globe with varying resolutions (Whelan, 2011). This allows us to then group together trips that were started (relatively) close by to obtain a number of trips taken at that approximate location at a particular time, n.total; this process also reduces the dimensionality of the dataset.  

Using a **reverse geocoding system**, we generate information about the location name/zip code associated with each longitude/latitude pair, resulting in additional variables borough and community district. Unfortunately, the library does not convert all our longitude / latitude combinations, leaving us with a number of trips, which we know are assigned within the bounds of NYC, but cannot link to any sub-locations. 

{% highlight python %}
import csv
import reverse_geocoder as rg
import pprint

# read earlier specified input filename  
locs = [(row[0], row[1]) for row in csv.reader(open(input_filename, 'rt'), delimiter = ',')]

# print out first 6 rows of csv file
pp = pprint.PrettyPrinter(indent = 4)
pp.pprint(locs[0:5])

# generate geolocations for lat/long coordinates in csv file
results = rg.search(locs)

# print some results
pp.pprint(results[0:2])

# match results to long/lat coordinates in csv file 
rows = []
for idx, loc in enumerate(locs):
    write_row = []
    lat = loc[0]
    lon = loc[1]
    gdata = results[idx]
    rows.append([lat,lon,gdata['name'],gdata['admin1'],gdata['admin2'],gdata['cc']])

# write to earlier specified output filename
csvwriter = csv.writer(open(output_filename,'wt'),delimiter=',')
csvwriter.writerows(rows)
{% endhighlight %}

Additionally, in order to be able to differentiate between types of trips taken, we break down the total number of trips by location and create four further variables n.yellow, n.green, n.uber, and n.bike that take on the number of trips taken in a location by yellow cab, green cab, Uber, and Citi Bike, respectively. 

Note that we are also using circular variables i.e. day of the month, day of the week, and hour of the day. These are variables that indicate cyclical time and are characterized by the fact that the beginning and the end of their scales meet. Most familiar statistics don’t work well with circular variables since they assume linearity, i.e. the lowest value being farthest from the highest value. For example, hours of a day, split into 24 bins (0 - 23), represent the daily cycle; 0, in this case, is much closer to 22 than to, say, 5. We tackle this issue by using cosine and sine functions  to place our circular variables into a standardized Cartesian space. This essentially makes it easier for the model to find relevant patterns (The Analysis Factor, n.d.). This creates 6 new variables: hour.num, hour.cos, hour.sin, wday.num, wday.cos, wday.sin.

{% highlight python %}
df$hour.num <- 2*pi*(df$hour+0.5)/24
df$wday.num <- 2*pi*(as.numeric(df$wday)+0.5)/24

df$hour.cos <- cos(df$hour.num)
df$hour.sin <- sin(df$hour.num)

df$wday.cos <- cos(df$wday.num)
df$wday.sin <- sin(df$wday.num)
{% endhighlight %}


Table 1 shows the metadata of our final dataset for analysis:

Variable Code|	Description| Level
---|---|---
month|	Month| 	Categorical
day|	Day of the month| 	Categorical
hour|	Hour of the day| 	Categorical
hour.num|	2*pi*(hour + 0.5)/24|	Numeric
hour.cos|	cos(hour.num)|	Numeric
hour.sin|	sin(hour.num)|	Numeric
n.total|	Total number of trips taken|	Numeric
n.uber|	Number of Uber trips taken|	Numeric
n.bike|	Number of Citi Bike trips taken|	Numeric
n.green|	Number of Green Taxi trips taken|	Numeric
n.yellow|	Number of Yellow Taxi trips taken|	Numeric
lat|	Latitude of location|	Numeric
lon|	Longitude of location|	Numeric
wday|	Weekday|	Categorical
wday.num|	2*pi*wday/7|	Numeric
wday.cos|	cos(wday.num)|	Numeric
wday.sin|	sin(wday.num)|	Numeric
wknd|	Weekend|	Binary
mean_temp|	Average temperature by day|	Numeric
precip_sum|	Total daily precipitation by day|	Numeric
#### Table 1 Metadata table



Data Exploration follow in Part 2.
