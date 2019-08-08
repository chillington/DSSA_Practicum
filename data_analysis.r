#Will Albert
#DSSA5302 - Summer 2019
#Data Practicum

#Data analysis phase

#Set working directory, load necessary libraries
#---------------------

#setwd("C:/Users/albertw/Desktop/practicum")

setwd("/home/will/datascience/dssa5302/practicum")

library(tidyverse)

#read the data
#----------
data <- read_csv("full_data_use.csv")

data %>% count(status)

ggplot(data, aes(x=low_201580))+
  geom_histogram()+
  facet_grid(rows=vars(status))

ggplot(data, aes(x=high_201580))+
  geom_histogram()+
  facet_grid(rows=vars(status))

ggplot(data, aes(x=low_201580, y=high_201580)) +
  geom_count()+
  facet_grid(rows=vars(status))+
  labs(x="Lowest Grade", y="Highest Grade", title="Highest by Lowest Grade, Fall 2015")

ggplot(data, aes(x=low_201620, y=high_201620)) +
  geom_count() +
  facet_grid(rows=vars(status))+
  labs(x="Lowest Grade", y="Highest Grade", title="Highest by Lowest Grade, Spring 2016")

ggplot(data, aes(x=TRANSFER_CREDITS))+
  geom_histogram()+
  facet_grid(rows=vars(status))

ggplot(data, aes(x=gens_courses))+
  geom_histogram()+
  facet_grid(rows=vars(status))

ggplot(data, aes(x=w_courses))+
  geom_histogram()+
  facet_grid(rows=vars(status))

ggplot(data, aes(x=status, y=gens_courses, color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)+
  labs(x="Student Status", y="# GENS Courses (mean)", title="General Studies Courses by Student Status")

ggplot(data, aes(x=status, y=TRANSFER_CREDITS, color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)+
  labs(x="Student Status", y="# Transfer Credits (mean)", title="Transfer Credits by Student Status")

ggplot(data, aes(x=status, y=w_courses, color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)+
  labs(x="Student Status", y="# Course Withdrawals (mean)", title="Course Withdrawals by Student Status")

ggplot(data, aes(x=status, y=tot_courses, color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)

ggplot(data, aes(x=status, y=(TRANSFER_CREDITS/96), color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)

ggplot(data, aes(x=status, y=high_201580, color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)

ggplot(data, aes(x=status, y=low_201580, color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)

ggplot(data, aes(x=status, y=high_201620, color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)

ggplot(data, aes(x=status, y=low_201620, color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)

ggplot(data, aes(x=status, y=(gens_courses/tot_courses), color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)

ggplot(data, aes(x=status, y=(w_courses/tot_courses), color=status))+
  geom_bar(stat="summary", fun.y="mean", width=0.5)
