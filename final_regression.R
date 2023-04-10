library(dplyr)
library(tidyverse)
library(readxl)
library(writexl)
library(ggplot2)
library(ggthemes)

# sets the working directory. 
setwd("C://Users//HUAWEI//Desktop//Projects//The-Pursuit-of-Happiness//Data")

# reads in the processed sunshine dataframe. 
initial_df <- read_xlsx('integrated_data.xls')

# defines the y and x variables to be used in the linear model
y = 'Life Ladder'

x <- c('Log GDP per capita', 'Social support',
       'Healthy life expectancy at birth', 'Freedom to make life choices',
       'Generosity', 'Perceptions of corruption', 'sun')

# a working dataframe with only y and x variables
df <- initial_df[y] %>% cbind(initial_df[x]) %>% tibble()

# checks if a row contains na values
check_row_clean <- function(row) {
  if(mean(is.na(row))>0) {
    return(FALSE)
  } 
  else{
    return(TRUE)
  }
}

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

# combines previous preprocessing steps
clean_data <- function(df) {
  # filters the dataframe for only na free rows
  clean_list <- apply(df, 1, check_row_clean)
  clean_df <- df[clean_list,]
  # converts the dataframe columns into z scores
  z_list <- apply(clean_df, 2, get_zscores)
  normalized_df <- as_tibble(z_list)
  return(normalized_df)
}

# returns a clean dataframe
clean_df <- clean_data(df)

# checks for remaining na values
#sum(is.na(clean_df))

# my personal plot theme for data visualizations. 
my_theme <- theme_economist_white(gray_bg = FALSE) +
  theme(plot.title = element_text(hjust = 0.5,
                                  vjust = 10,
                                  size = 10,
                                  color = "#474747"),
        plot.margin = unit(c(1.5, 1, 1.5, 1), "cm"),
        axis.text = element_text(size = 9,
                                 color = "gray30"),
        axis.text.x=element_text(vjust = -2.5),
        axis.title.x = element_text(size = 9,
                                    color = "gray30",
                                    vjust = -10),
        axis.title.y = element_text(size = 9,
                                    color = "gray30",
                                    vjust = 10),
        legend.direction = "vertical", 
        legend.position = "right",
        legend.title = element_blank(),
        legend.text = element_text(size = 11,
                                   color = "gray20"),
        legend.margin=margin(1, -15, 1, 0),
        legend.spacing.x = unit(0.25, "cm"),
        legend.key.size = unit(1, "cm"), 
        legend.key.height = unit(0.75, "cm"),
        strip.text = element_text(hjust = 0.5,
                                  vjust = 1,
                                  size = 10,
                                  color = "#474747"),
        panel.spacing = unit(2, "lines"))



# renames the life ladder column
clean_df <- rename(clean_df, life_ladder = 'Life Ladder')

# creates a faceted scatter plot
clean_df %>%
  gather(key=measure, value='value', -1) %>%
  filter(measure != 'sun') %>%
  ggplot(aes(y=life_ladder, x=value, col=measure)) +
  geom_point() +
  geom_smooth(method='lm', formula=y~x) +
  ggtitle("") +
  facet_wrap(~measure, scales="free") +
  xlab("") +
  ylab("") +
  my_theme +
  theme(legend.position = "none")

# runs a basic linear model
lm1 <- lm(clean_df$life_ladder ~ ., data=clean_df)
summary(lm1)

# creates a list of European countries
europe <- c('Albania', 'Austria', 'Belgium', 'Bosnia and Herzegovina',
            'Bulgaria', 'Croatia', 'Cyprus', 'Denmark', 'Estonia',
            'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Iceland',
            'Ireland', 'Italy', 'Latvia', 'Lithuania', 'Malta', 'Moldova',
            'Montenegro', 'Netherlands', 'North Macedonia', 'Norway', 'Poland',
            'Portugal', 'Romania', 'Serbia', 'Slovakia', 'Slovenia', 'Spain',
            'Sweden', 'Switzerland', 'Ukraine', 'United Kingdom')

# filters the initial dataframe for European countries
europe_df <- initial_df[initial_df$`Country name` %in% europe,]

# a working dataframe with only y and x variables
new_df <- europe_df[y] %>% cbind(europe_df[x]) %>% tibble()

# returns a clean dataframe
clean_europe_df <- clean_data(new_df)

# checks for remaining na values
#sum(is.na(clean_europe_df))

# reads in original dataframe with regional information included. 
regional_data <- read_xlsx('regional_data_labels.xlsx')

# simplifies regional data labels for readability
regional_data[regional_data$Region=='Central and Eastern Europe',]$Region <- 'The West'
regional_data[regional_data$Region=='Western Europe',]$Region <- 'The West'
regional_data[regional_data$Region=='Latin America and Caribbean',]$Region <- 'Latin America'
regional_data[regional_data$Region=='Eastern Asia',]$Region <- 'Asia'
regional_data[regional_data$Region=='Southeastern Asia',]$Region <- 'Asia'
regional_data[regional_data$Region=='Southern Asia',]$Region <- 'Asia'
regional_data[regional_data$Region=='Australia and New Zealand',]$Region <- 'The West'
regional_data[regional_data$Region=='North America',]$Region <- 'The West'
regional_data[regional_data$Region=='Middle East and Northern Africa',]$Region <- 'MENA'

regional_data %>%
  ggplot(aes(x=regional_data$`Economy (GDP per Capita)`, y=regional_data$`Happiness Score`, col=Region)) +
  geom_point() +
  xlab('GDP per capita (score)') +
  ylab('Happiness (Score)') +
  ggtitle('Regional breakdown') +
  my_theme

# creates a faceted scatter plot
clean_df %>%
  ggplot(aes(y=life_ladder, x=sun, col='orange')) +
  geom_point(alpha=0.8) +
  geom_smooth(method='lm', formula=y~x) +
  ggtitle("Target variable") +
  xlab("Sunshine hours") +
  ylab("Happiness") +
  my_theme +
  theme(legend.position = "none")



# runs a basic linear model
lm2 <- lm(clean_europe_df$`Life Ladder` ~ ., data=clean_europe_df)
summary(lm2)


# creates a faceted scatter plot
clean_df %>%
  ggplot(aes(y=life_ladder, x=sun)) +
  geom_point(size = 1, alpha=0.6, col='purple') +
  geom_smooth(method='lm', formula=y~x) +
  ggtitle("Sunshine hours") +
  xlab("Sunshine hours") +
  ylab("Happiness") +
  my_theme +
  theme(legend.position = "none",
        plot.margin = unit(c(2, 2, 2, 2), "cm"))



