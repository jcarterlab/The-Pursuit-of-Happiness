library(dplyr)
library(tidyverse)
library(readxl)
library(writexl)

# sets the working directory. 
setwd("C://Users//HUAWEI//Desktop//Projects//The-Pursuit-of-Happiness//Data")

# reads in the original dataframe. 
full_df <- read_excel("sunshine_data.xls")

# selects only the desired columns
targeted_df <- full_df[,c('Country','Year')]

# returns the number of unique country names
unique <- unique(targeted_df$Country)

# gets a list of average sunshine hours for each country
averages <- list()
for(i in 1:length(unique)) {
  averages[i] <- mean(targeted_df[targeted_df$Country == unique[i],]$Year)
}

# creates a final dataframe
final_df <- tibble(
  country = unique,
  sun = unlist(averages)
)

# saves the data as an xls file
write_xlsx(final_df, 'processed_sunshine_data.xls')
