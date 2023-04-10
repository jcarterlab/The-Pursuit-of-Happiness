library(dplyr)
library(tidyverse)
library(readxl)
library(writexl)

# sets the working directory. 
setwd("C://Users//HUAWEI//Desktop//Projects//The-Pursuit-of-Happiness//Data")

# reads in the original dataframe. 
full_df <- read_excel("happiness_data.xls")

# selects only the desired colums
keep_cols <- c(1,3,4,5,6,7,8,9)
targeted_df <- full_df[,keep_cols]

# checks if a row contains na values
check_row_clean <- function(row) {
  if(mean(is.na(row))>0) {
    return(FALSE)
  } 
  else{
    return(TRUE)
  }
}

# filters the dataframe for only na free rows
clean_list <- apply(targeted_df, 1, check_row_clean)
clean_df <- targeted_df[clean_list,]

# saves the data as an xls file
write_xlsx(clean_df, 'processed_happiness_data.xls')


