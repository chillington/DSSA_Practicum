#Will Albert
#DSSA5302 - Summer 2019
#Data Practicum

#Preparing data for neural network input

#Set working directory, load necessary libraries
#---------------------

#setwd("C:/Users/albertw/Desktop/practicum")

setwd("/home/will/datascience/dssa5302/practicum")

library(tidyverse)

#read the data
#----------
data <- read_csv("full_data_use.csv")

glimpse(data)

data_adj <- data %>%
  mutate(high_fall=(high_201580/4),
         low_fall=(low_201580/4),
         high_spring=(high_201620/4),
         low_spring=(low_201620/4),
         gens_prop=(gens_courses/tot_courses),
         w_prop=(w_courses/tot_courses),
         tcred_prop=(TRANSFER_CREDITS/96))
glimpse(data_adj)

data_for_nn <- data_adj %>%
  select(id, high_fall, low_fall, high_spring, low_spring, w_prop, tcred_prop,
         inactive, continuing, graduated)
#made the decision to get rid of gens_prop; only use 6 variables
glimpse(data_for_nn)
data_for_nn[1:20,]

write_csv(data_for_nn, "data_for_nn.csv")
