library(dplyr)
library(tidyverse)
library(readxl)
library(ggplot2)

# sets the working directory. 
setwd("C://Users//HUAWEI//Desktop//Projects//The-Pursuit-of-Happiness//Data")

# reads in the original dataframe. 
full_df <- read_excel("happiness_data.xls")

# filters the dataframe for values from 2021 
#full_df <- original_df %>% filter(year == 2021)

# defines the y and x variables to be used in the linear model
y = 'Life Ladder'

x <- c('Log GDP per capita', 'Social support',
       'Healthy life expectancy at birth', 'Freedom to make life choices',
       'Generosity', 'Perceptions of corruption')

# a working dataframe with only y and x variables
df <- full_df[y] %>% cbind(full_df[x]) %>% tibble()

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
clean_list <- apply(df, 1, check_row_clean)
clean_df <- df[clean_list,]

# checks the distributions 
get_hists <- function(df, disclude=NULL, numeric=FALSE) {
  new_df <- gather(df, key='predictor', value='value', -disclude)
  if(numeric==TRUE) {
    new_df$predictor <- as.numeric(new_df$predictor)
  }
  ggplot(new_df, aes(x=value, order=predictor, fill=predictor)) + 
    geom_histogram() +
    facet_wrap(~predictor, scales = "free", ncol=3) +
    labs(title='', x='', y='') +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5),
          legend.position = "none")
}
get_hists(clean_df,disclude=1)

# # gets histograms for a column based on a range of transformations
get_trans <- function(df, col, trans, numeric) {
  new_df <- tibble(df[col])
  for(i in 1:length(trans)) {
    new_df[i] <- df[col]**(1/trans[i])
  }
  colnames(new_df) <- trans
  get_hists(new_df,numeric=numeric)
}
get_trans(df=clean_df,
          col="Social support",
          trans=c(seq(0.1,1,0.1)),
          numeric=TRUE)

# transformations
#clean_df$`Freedom to make life choices` <- clean_df$`Freedom to make life choices`**(1/0.4)
#clean_df$Generosity <- clean_df$Generosity**(1/2.7)
#clean_df$`Healthy life expectancy at birth` <- clean_df$`Healthy life expectancy at birth`**(1/0.5)
#clean_df$`Perceptions of corruption` <- clean_df$`Perceptions of corruption`**(1/0.3)
#clean_df$`Social support` <- clean_df$`Social support`**(1/0.4)

# re-checks the transformations
#get_hists(clean_df,disclude=1)


# plots tthe distributions as scatter plots 
get_scaters <- function(df) {
  new_df <- gather(df, key='predictor', value='value', -1)
  new_df %>% ggplot(aes(x=new_df$value, 
                        y=new_df$`Life Ladder`, 
                        color=new_df$predictor)) + 
    geom_point(alpha=0.75) +
    geom_smooth() +
    facet_wrap(~new_df$predictor, scales = "free", ncol=3) +
    labs(title='', x='', y='') +
    theme_classic() +
    theme(plot.title = element_text(hjust = 0.5),
          legend.position = "none") 
}
get_scaters(clean_df)

# calculates z scores for a given column
get_zscores <- function(col) {
  avg <- mean(col)
  sd <- sd(col)
  z_scores <- list()
  for(i in 1:length(col)) {
    z_scores[i] <- (col[i]-avg) / sd
  }
  return(unlist(z_scores))
}
# converts the dataframe columns into z scores
z_list <- apply(clean_df, 2, get_zscores)
normalized_df <- as_tibble(z_list)

# creates a heat map of the correlations
res <- cor(normalized_df[-1])
col <- colorRampPalette(c("darkblue", "white", "darkred"))(20)
heatmap(x = res, col = col, symm = TRUE)

# runs a basic linear model
lm1 <- lm(normalized_df$`Life Ladder` ~ ., data=normalized_df)
summary(lm1)
