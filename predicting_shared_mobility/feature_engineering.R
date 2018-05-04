
### Create additional features ###

df <- read.csv('NYC_mobility_geocoded')

df$hour.num <- 2*pi*(df$hour+0.5)/24
df$wday.num <- 2*pi*(as.numeric(df$wday)+0.5)/24

df$hour.cos <- cos(df$hour.num)
df$hour.sin <- sin(df$hour.num)

df$wday.cos <- cos(df$wday.num)
df$wday.sin <- sin(df$wday.num)

write.csv(df, 'NYC_mobility_geocoded_fin.csv')
