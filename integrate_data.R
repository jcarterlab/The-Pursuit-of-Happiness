library(dplyr)
library(tidyverse)
library(readxl)
library(writexl)

# sets the working directory. 
setwd("C://Users//HUAWEI//Desktop//Projects//The-Pursuit-of-Happiness//Data")

# reads in the processed sunshine dataframe. 
happiness_df <- read_xlsx('processed_happiness_data.xls')

# reads in the processed sunshine dataframe. 
sunshine_df <- read_xlsx('processed_sunshine_data.xls')

# creates a list of unique country names for each dataframe
happiness_countries <- unique(happiness_df$`Country name`)
sunshine_countries <- unique(sunshine_df$country)

# creates a list of matching and non-matching countries
get_matching_countries <- function() {
  matches <- list()
  for(i in 1:length(sunshine_countries)) {
    if(sunshine_countries[i] %in% happiness_countries) {
      matches[i] <- TRUE
    } else {
      matches[i] <- FALSE
    }
  }
  return(unlist(matches))
} 
matching_countries <- sunshine_countries[get_matching_countries()]
sunshine_countries[get_matching_countries()==FALSE]

# changes the names of sunshine data countries to get more matches
old <- c('Congo', 'Czech Republic', 'Democratic Republic of the Congo', 'Taiwan')
new <- c('Congo (Brazzaville)', 'Czechia', 'Congo (Kinshasa)', 'Taiwan Province of China')

for(i in 1:length(old)) {
  sunshine_countries[sunshine_countries==old[i]] <- new[i]
}

# filters both dataframes so that only matching countries remain
matches <- sunshine_countries[get_matching_countries()]
happiness_df <- happiness_df %>% filter(happiness_df$`Country name` %in% matches)
sunshine_df <- sunshine_df %>% filter(sunshine_df$country %in% matches)

# checks there are the same number of unique country names
unique(happiness_df$`Country name`)
unique(sunshine_df$country)

# filters country names from happiness df not in sunshine df
happiness_df <- happiness_df %>% filter(happiness_df$`Country name` %in% unique(sunshine_df$country))

# checks the sorted country names for errors
mean( sort(unique(happiness_df$`Country name`)) == sort(sunshine_df$country) )

# creates the right number of duplicate rows for each country for the sunshne dataframe
get_duplicates <- function(i) {
  len = nrow(happiness_df[happiness_df$`Country name`==countries[i],])
  x = sunshine_df[i,]
  return(tibble(data.frame(lapply(x, rep, len))))
}
countries <- unique(happiness_df$`Country name`)
new_sunshine_df <- bind_rows(lapply(1:length(countries),get_duplicates))

# combines the happiness and duplicated sunshine data
final_df <- tibble(happiness_df %>% cbind(new_sunshine_df[,2]))

# saves the data as an xls file
write_xlsx(final_df, 'integrated_data.xls')



