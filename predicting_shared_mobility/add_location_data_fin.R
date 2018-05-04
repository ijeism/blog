library(plyr)
library(dplyr)

# read in single trip file and remove any rows containing missing long/lat values
sm <- read.csv('Shared_mobility_Precision_6_filtered.csv')
sm %>% filter(lat == 0 | long == 0)

# write out as csv
write.csv(sm, '')

# subset only long/lat coordinates for further processing in python using reverse-geocoder + write out as csv
coords <- sm %>% select(lat, long)
write.table(coords, file = 'Shared_mobility_P6_coordinates.csv', row.names = F, col.names = F, sep = ',')

# read in geocoded file produced in python
res <- read.csv("Shared_mobility_P6_coordinates_geocoded.csv", header = F)

# append colums by row position (since long/lat coordinates are ordered the exact same way in both files)
final <- bind_cols(sm,res)

# Verify that long/lat coordinates of both files match in any given row
nrow(filter(final, lat != V1 | long != V2)) # should be zero

# clean up 
final <- select(final, -c(X,V1,V2,V6))
names(final)[16:18] <- c('Name', 'State', 'County')

# write to csv
write.csv(final, 'NYC_mobility_geocoded')
