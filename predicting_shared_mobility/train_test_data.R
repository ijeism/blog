library(plyr) # always load plyr before loading dplyr
library(dplyr)

df <- read.csv('NYC_mobility_geocoded_fin.csv')

df$month <- factor(df$month, levels = c('April', 'May', 'June'))
df <- arrange(df, month, day, hour)

test <- filter(df, month == 'June' & day >= 24 & day <=30)
train <- filter(df, month == 'April' | month == 'May' | (month == 'June' & day <= 23))
test <- select(test, -X)
train <- select(train, -X)

write.csv(train, 'train.csv')
write.csv(test, 'test.csv')