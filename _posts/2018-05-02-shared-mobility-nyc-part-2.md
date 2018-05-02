---
published: true
layout: post
categories: machine learning; EDA
author: I ON
---
# Predicting NYC Shared Mobility - Exploratory Data Analysis

Following data pre-processing in Part 1 of this series, we conduct exploratory data analysis using R. 

### Cyclical trends of demand

Figure 1 depicts the cyclical trend of pickups throughout a week. Taxi, Uber, and Bike follow a similar cyclical trend in the sense that activity is high on weekdays and comparatively low on weekends. Activity for both taxi and Uber seems to peak on Wednesdays, while bike activity remains relatively stable across weekdays. On weekends, bike demand seems higher on Sundays, while Sundays show the lowest pickup activity for Taxi and Uber. Notice also how activity for Uber and Taxi tends to be highest on days with low temperatures, while this observation is not as clear from the bike graph.
 

![Picture1.png]({{site.baseurl}}/assets/Picture1.png)
 
Figure 1 Demand by weekday

R code:

{% highlight r %}
# scatterplot of count versus weekday, with color scale based on temp
p1 <- ggplot(ny, aes(wday, combined)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') +
  theme_minimal()
p2 <- ggplot(ny, aes(wday, taxi)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') +
  theme_minimal()
p3 <- ggplot(ny, aes(wday, uber)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') +
  ylim(0, 2000) +
  theme_minimal()
p4 <- ggplot(ny, aes(wday, bike)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') +
  theme_minimal()
grid.arrange(p1, p2, p3, p4, ncol = 2, top = 'No of Pickups vs Weekday (by mean temperature)')
{% endhighlight %}

Figure 2 shows that on working days (first row), peak activity typically occurs during the morning hours (around 8am) and right after close of business (around 5pm), with somewhat increased activity also around lunchtime. This is the case across each type of transportation, although there are differences in the distribution of pickup activity throughout the day. 

Notice, again, that maximum pickup counts for Taxi and Uber seem to be highest when mean temperatures are lowest, while pickup activity on days with lower temperature tends to be lower for the Bike. This makes sense, since bike users are more exposed to weather conditions than car users.

On the other hand, pickup activity on non-working days (second row) follow a different pattern. Pickups for Taxi and Uber in particular are high during the very early morning hours (perhaps when people return home from a night out) and have another peak in the afternoon hours, with a slightly different distribution. Again, highest count tends to occur on days with low mean temperatures. Bike activity also shows a steady rise and fall during the afternoon hours, although to a much lesser extent on cooler days; somewhat increased activity equally occurs during early morning hours (from around midnight till 3-4 am).


![Picture1.png]({{site.baseurl}}/assets/Picture2.png)

Figure 2 Demand by hour (weekday vs. weekend)

R code:
{% highlight r %}
# scatterplot of count versus hour, with color scale based on temp
pl1 <- ggplot(filter(ny, wknd == 0), aes(hour, combined)) 
pl1 <- pl1 + geom_point(position = position_jitter(w = 1, h = 0), aes(color = mean_temp), alpha = 0.5)
#pl1 <- pl1 + scale_color_gradientn(colours = c('dark blue','blue','light blue','light green','yellow','orange','red'))
pl1 <- pl1 + scale_color_continuous(low = '#00A8C5', high='#FFFF7E')
pl1 + theme_minimal()

pl2 <- ggplot(filter(ny, wknd == 0), aes(hour, uber)) 
pl2 <- pl2 + geom_point(position = position_jitter(w = 1, h = 0), aes(color = mean_temp), alpha = 0.5)
#pl2 <- pl2 + scale_color_gradientn(colours = c('dark blue','blue','light blue','light green','yellow','orange','red'))
pl2 <- pl2 + scale_color_continuous(low = '#00A8C5', high='#FFFF7E')
pl2 + theme_minimal()

pl3 <- ggplot(filter(ny, wknd == 0), aes(hour, bike)) 
pl3 <- pl3 + geom_point(position = position_jitter(w = 1, h = 0), aes(color = mean_temp), alpha = 0.5)
#pl3 <- pl3 + scale_color_gradientn(colours = c('dark blue','blue','light blue','light green','yellow','orange','red'))
pl3 <- pl3 + scale_color_continuous(low = '#00A8C5', high='#FFFF7E') 
pl3 + theme_minimal()

pl4 <- ggplot(filter(ny, wknd == 1), aes(hour, combined)) 
pl4 <- pl4 + geom_point(position = position_jitter(w = 1, h = 0), aes(color = mean_temp), alpha = 0.5)
#pl4 <- pl4 + scale_color_gradientn(colours = c('dark blue','blue','light blue','light green','yellow','orange','red'))
pl4 <- pl4 + scale_color_continuous(low = '#00A8C5', high='#FFFF7E')
pl4 + theme_minimal()

pl5 <- ggplot(filter(ny, wknd == 1), aes(hour, uber)) 
pl5 <- pl5 + geom_point(position = position_jitter(w = 1, h = 0), aes(color = mean_temp), alpha = 0.5)
#pl5 <- pl5 + scale_color_gradientn(colours = c('dark blue','blue','light blue','light green','yellow','orange','red'))
pl5 <- pl5 + scale_color_continuous(low = '#00A8C5', high='#FFFF7E')
pl5 + theme_minimal()

pl6 <- ggplot(filter(ny, wknd == 1), aes(hour, bike)) 
pl6 <- pl6 + geom_point(position = position_jitter(w = 1, h = 0), aes(color = mean_temp), alpha = 0.5)
#pl6 <- pl6 + scale_color_gradientn(colours = c('dark blue','blue','light blue','light green','yellow','orange','red'))
pl6 <- pl6 + scale_color_continuous(low = '#00A8C5', high='#FFFF7E')
pl6 + theme_minimal()

grid.arrange(pl1, pl2, pl3, pl4, pl5, pl6, ncol = 3, top = 'No of Pickups vs Hour\nWeekday', bottom = 'Weekend')
{% endhighlight %}


## Location

Figure 3 clearly shows a strong relationship between location and number of pickups. Pickup activity is focused on particular areas within NYC, which is reflected by higher counts (larger point sizes on the scatterplot) at certain lat/long intersections. Comparing the graphs for Taxi, Uber, and Bike, we can make out only subtle differences between the operation areas of the three transportation types (not depicted here). Overall there is a significant focus on the Manhattan area.

![Picture1.png]({{site.baseurl}}/assets/Picture3.png) 

Figure 3 Demand by location (Latitude vs. Longitude, by number of pickups)

## Precipitation

Figure 4 illustrates the relationship between pickups and amount of rainfall and clearly shows how Bike pickups decrease with increasing precipitation. Uber pickups, on the other hand, seem to increase with precipitation while Taxi activity tends to drop with increased rainfall. 

![Picture1.png]({{site.baseurl}}/assets/Picture4.png) 

Figure 4 Demand by rainfall (number of pickups vs. precipitation, by mean temperature)

R code for all visualizations can be found at XXX.