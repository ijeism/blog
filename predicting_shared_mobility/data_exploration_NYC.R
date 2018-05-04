library(plyr)
library(dplyr)
library(ggplot2)
library(reshape2)
library(corrplot)
library(grid)
library(gridExtra)
library(lattice)

ny <- read.csv('NYC_mobility_geocoded_fin.csv')

ny <- select(ny, -c(X.1,X))
ny$taxi <- ny$n.yellow + ny$n.green
ny <- select(ny, -c(n.yellow, n.green))
ny <- rename(ny, uber = n.uber, bike = n.bike, combined = n.total)

# reshape data for the small multiple chart using reshape2
library(reshape2)
melt.ny <- melt(ny)
ggplot(melt.ny, aes(x = value)) + stat_density() + facet_wrap(~variable, scales = 'free')


# corrPlot
df <- ny %>% select(-c(X, n.uber, n.bike, n.green, n.yellow, log.total))
num.cols <- sapply(df, is.numeric)
cor.data <- cor(df[, num.cols])
corrplot(cor.data, moethod = 'color')

# scatter plot of count vs temp
ggplot(ny, aes(mean_temp, n.total)) + geom_point(alpha = 0.2, aes(color = mean_temp)) + theme_minimal()
ggplot(ny, aes(mean_temp, n.bike)) + geom_point(alpha = 0.2, aes(color = mean_temp)) + theme_minimal()

# plotting count versus datetime as a scatterplot with a color gradient based on temperature
# creating numeric variable for 'month'
attach(ny)
ny$mm[month == 'April'] <- 4
ny$mm[month == 'May'] <- 5
ny$mm[month == 'June'] <- 6
detach(ny)

# converting to datetime variable
ny$datetime <- ISOdatetime(2014, ny$mm, ny$day, ny$hour, 0, 0)

# scatterplot of count versus datetime, with color scale based on temp
p1 <- ggplot(ny, aes(datetime, combined)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#55D8CE', high='#FF6E2E') + theme_minimal()
p2 <- ggplot(ny, aes(datetime, taxi)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#55D8CE', high='#FF6E2E') + theme_minimal()
p3 <- ggplot(ny, aes(datetime, uber)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#55D8CE', high='#FF6E2E') + theme_minimal()
p4 <- ggplot(ny, aes(datetime, bike)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#55D8CE', high='#FF6E2E') + theme_minimal()
grid.arrange(p1, p2, p3, p4, ncol = 2, top = 'No of Pickups vs DateTime (by mean temperature)')

# rearrange wday levels so they follow typical mon-sun sequence
ny$wday <- factor(ny$wday, levels = c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'))

# scatterplot of count versus weekday, with color scale based on temp
p1_ <- ggplot(ny, aes(wday, combined)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') +
  theme_minimal()
p2_ <- ggplot(ny, aes(wday, taxi)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') +
  theme_minimal()
p3_ <- ggplot(ny, aes(wday, uber)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') +
  ylim(0, 2000) +
  theme_minimal()
p4_ <- ggplot(ny, aes(wday, bike)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') +
  theme_minimal()
grid.arrange(p1_, p2_, p3_, p4_, ncol = 2, top = 'No of Pickups vs Weekday (by mean temperature)')

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

# scatterplots of count vs long/lat
p5 <- ggplot(ny, aes(lat, combined)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#55D8CE', high='#FF6E2E') + theme_minimal()
p6 <- ggplot(ny, aes(long, combined)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#55D8CE', high='#FF6E2E') + theme_minimal()

grid.arrange(p5, p6, ncol = 2)

# scatterplot of long vs lat, by total number of pickups
p7 <- ggplot(ny, aes(long, lat)) + geom_point(aes(color = combined, size = combined), alpha = 0.5) +
  scale_color_continuous(low = '#A9EEE6', high='#6A1B9A') + theme_minimal()
p8 <- ggplot(ny, aes(long, lat)) + geom_point(aes(color = taxi, size = taxi), alpha = 0.5) +
  scale_color_continuous(low = '#A9EEE6', high='#6A1B9A') + theme_minimal()
p9 <- ggplot(ny, aes(long, lat)) + geom_point(aes(color = uber, size = uber), alpha = 0.5) +
  scale_color_continuous(low = '#A9EEE6', high='#6A1B9A') + theme_minimal()
p10 <- ggplot(ny, aes(long, lat)) + geom_point(aes(color = bike, size = bike), alpha = 0.5) +
  scale_color_continuous(low = '#A9EEE6', high='#6A1B9A') + theme_minimal()

grid.arrange(p7, p8, p9, p10, ncol = 2, top = 'Latitude vs Longitude by number of pickups')

# scatterplot of precipitation vs pickups, by temperature
p11 <- ggplot(ny, aes(precip_sum, combined)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') + theme_minimal()
p12 <- ggplot(ny, aes(precip_sum, taxi)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') + theme_minimal()
p13 <- ggplot(ny, aes(precip_sum, uber)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') + theme_minimal()
p14 <- ggplot(ny, aes(precip_sum, bike)) + geom_point(aes(color = mean_temp), alpha = 0.5) + 
  scale_color_continuous(low = '#00A8C5', high='#FFFF7E') + theme_minimal()
grid.arrange(p11, p12, p13, p14, ncol = 2, top = 'No of Pickups vs Precipitation (by mean temperature)')

# reshape data to extract count by type
ss <- ny %>% select(uber, bike, taxi, hour, wknd)
type.ny <- melt(ss, id.vars = c('hour', 'wknd'), variable.name = 'type', value.name = 'n.pickups')

