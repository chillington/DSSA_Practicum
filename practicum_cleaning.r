#Will Albert
#DSSA5302 - Summer 2019
#Data Practicum

#Cleaning and building data prior to analysis

#R version 3.6.0

#Set working directory, load necessary libraries
#---------------------

#setwd("C:/Users/albertw/Desktop/practicum")

setwd("/home/will/datascience/dssa5302/practicum")

library(tidyverse)
library(readxl)


#First, the course data - all courses for all requested student ID's
#---------------------
#the 4th column needs to be numeric, so set that manually
courses_full <- read_excel("WA_Cohort_Courses.xls", col_types = c("text", "text", "text", 
                                                                  "numeric", "text", "text", "text"))
#take a look
glimpse(courses_full)
#how many students?
students <- courses_full$Z_NUMBER %>% unique()
#mark rows with courses before term=201580 (fall 2015; new students' first term)
courses_full$returning <- ifelse(courses_full$COURSE_TERM < 201580, 1, 0)
#mark if transfer course by looking for "T" in grade column
courses_full$transfer_course <- ifelse(grepl("T", courses_full$COURSE_GRADE), "yes", "no")
#filter to get only non-transfer courses
stk_courses <- filter(courses_full, transfer_course=="no")
#make sure everything looks good
glimpse(stk_courses)
#filter for courses prior to 201580, indicating returning students
returning_students <- filter(stk_courses, returning==1)
#filter to remove those students
new_students <- filter(stk_courses, !stk_courses$Z_NUMBER %in% returning_students$Z_NUMBER)
#check it
glimpse(new_students)
#check terms in new dataframe
new_students %>% 
  count(COURSE_TERM)
#filter to get only rows with term=201580 (fall 2015) or 201620 (spring 2016); first full academic year
new_yr1 <- filter(new_students, new_students$COURSE_TERM==201580 | new_students$COURSE_TERM==201620)
#make sure we got the terms we wanted
new_yr1 %>% 
  count(COURSE_TERM)
#list general studies course abbreviations
gens <- c("FRST", "GAH", "GEN", "GIS", "GNM", "GSS")
#mark rows if they are general studies
new_yr1$g_course <- ifelse(new_yr1$COURSE_SUBJ %in% gens, 1, 0)
#check with new variable
glimpse(new_yr1)
#check grade possibilities (and count them)
new_yr1 %>%
  count(COURSE_GRADE)
##consider listing grades to exclude
#exclude_grades <- c("NC", "P", "X")
##consider marking classes with grades to exclude
#new_yr1$exclude_grade <- ifelse(new_yr1$COURSE_GRADE %in% exclude_grades, 1, 0)
##consider recording possible grades to exclude in a new dataframe
#excluded_df <- filter(new_yr1, new_yr1$exclude_grade==1)
#create a dataframe with the total number of courses for each student
tot_courses_data <- new_yr1 %>%
  count(Z_NUMBER) %>%
  rename(tot_courses=n)
#look
glimpse(tot_courses_data)
#get a dataframe with just general studies courses
gens_df <- filter(new_yr1, new_yr1$g_course==1)
#dataframe with number of gens courses for each student
gens_data <- gens_df %>%
  count(Z_NUMBER) %>%
  rename(gens_courses=n)
#dataframe with courses where students voluntarily withdrew
withdrawals_df <- filter(new_yr1, new_yr1$COURSE_GRADE=="W")
#dataframe with number of courses from which each student withdrew
w_data <- withdrawals_df %>%
  count(Z_NUMBER) %>%
  rename(w_courses=n)
#list grades to keep
COURSE_GRADE <- c("A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D+", "D", "D-", "F")
#list number values for letter grades
num_grade <- c(4.0, 3.7, 3.3, 3.0, 2.7, 2.3, 2.0, 1.7, 1.3, 1.0, 0.7, 0)
#make a tibble with letter grades and their corresponding number values
grades <- tibble(COURSE_GRADE, num_grade)
#select only courses with grades to keep
data1 <- filter(new_yr1, new_yr1$COURSE_GRADE %in% grades$COURSE_GRADE)
#add the values by joining
data2 <- right_join(data1, grades)
#make sure it worked
glimpse(data2)
#make sure we have only the grades we wanted
data2 %>%
  count(COURSE_GRADE)
#get just student id and number grade
data3 <- data2 %>%
  select(Z_NUMBER, num_grade)
#separate dataframes for each term
courses_201580 <- filter(data3, data2$COURSE_TERM==201580)
courses_201620 <- filter(data3, data2$COURSE_TERM==201620)
#get each student's lowest grade for 201580
low_201580 <- courses_201580 %>% 
  group_by(Z_NUMBER) %>%         #for each student
  arrange(num_grade) %>%         #sort grades in order
  filter(row_number()==1) %>%    #take the first row
  rename(low_201580=num_grade)   #rename grade column
#and highest for 201580
high_201580 <- courses_201580 %>% 
  group_by(Z_NUMBER) %>% 
  arrange(num_grade) %>% 
  filter(row_number()==n())%>%
  rename(high_201580=num_grade)
#low for 201620
low_201620 <- courses_201620 %>% 
  group_by(Z_NUMBER) %>% 
  arrange(num_grade) %>% 
  filter(row_number()==1)%>%
  rename(low_201620=num_grade)
#high for 201620
high_201620 <- courses_201620 %>% 
  group_by(Z_NUMBER) %>% 
  arrange(num_grade) %>% 
  filter(row_number()==n())%>%
  rename(high_201620=num_grade)
#join each student's highest and lowest grade for each term
highlow_201580 <- full_join(high_201580, low_201580)
highlow_201620 <- full_join(high_201620, low_201620)
#join the terms together so that each row is one student with highest and lowest grade each term
highlow_all <- full_join(highlow_201580, highlow_201620)
#see how it looks
glimpse(highlow_all)
#look at the first 20 rows
highlow_all[1:20,]
#join the number of gens courses for each student
highlow_all_gens <- full_join(highlow_all, gens_data)
#join the number of withdrawals for each student
data4 <- full_join(highlow_all_gens, w_data)
#make sure we have the same students in the total courses dataframe
tot_courses_data2 <- tot_courses_data %>% 
  filter(tot_courses_data$Z_NUMBER %in% data4$Z_NUMBER)
#join the total courses for each student
data5 <- full_join(data4, tot_courses_data2)
#look at the first 20
data5[1:20,]
#replace the NA values for gens and withdrawals with 0
data5 <- data5 %>% 
  replace_na(list(gens_courses = 0, w_courses = 0))
#remove the students who did not take courses in either 201580 or 201620
course_data <- data5 %>% 
  filter(!is.na(high_201580) & !is.na(high_201620))
#first 20
course_data[1:20,]

#save the data we're going to use
write_csv(course_data, "course_data_to_use.csv")

#clean this place up!
rm(courses_201580, courses_201620, courses_full, data1, data2, data3, data4, data5,
   excluded_df, gens_data,gens_df, grades, high_201580, high_201620, low_201580, low_201620,
   highlow_201580, highlow_201620, highlow_all, highlow_all_gens, new_students, new_yr1, 
   returning_students, stk_courses, tot_courses_data, tot_courses_data2, w_data, withdrawals_df, 
   COURSE_GRADE, exclude_grades, gens, num_grade)

#in case i need to reopen the course data file:
#-----
course_data <- read.csv("course_data_to_use.csv")

#Next, the file with transfer credits and degree info.
#------------------

student_info <- read_excel("WA_Cohort_Info.xls")
#see what we have
glimpse(student_info)
#get only students in our course_data dataframe
student_data1 <- student_info %>%
  filter(student_info$Z_NUMBER %in% course_data$Z_NUMBER)
#check the first 30
student_data1[1:30,]
#glimpse is better with this many variables (40)
glimpse(student_data1)
#make dataframe with just id and number of transfer credits, one row per student
tcredits <- student_data1 %>%
  select(Z_NUMBER, TRANSFER_CREDITS) %>%       #just id and transfer credits
  replace_na(list(TRANSFER_CREDITS=0)) %>%     #make sure no transfer credits = 0 (not NA)
  distinct()    #ensuring one row for each student
#what's it look like?
glimpse(tcredits)
#great! join that to the original course_data dataframe
courses_tcredits <- full_join(course_data, tcredits)

##now I need to make 3 variables indicating if a student graduated, left early, or is continuing
#check student status variable
student_data1 %>%
  count(CUR_STU_STATUS_DESC)
#make sure we only have undergraduate records
student_data2 <- filter(student_data1, GRAD_LEVL=="U"| is.na(GRAD_LEVL))
#count grad level
student_data2 %>%
  count(GRAD_LEVL)
#count graduation status
student_data2 %>%
  count(GRAD_STAT_DESC)
#count level in degree works
student_data2 %>%
  count(DW_LEVL)
#get a crosstab for student status by grad status
student_data2 %>%
  group_by(CUR_STU_STATUS_DESC, GRAD_STAT_DESC) %>%
  summarize(n=n()) %>%
  spread(GRAD_STAT_DESC, n)
#crosstab for grad status and degree works level
student_data2 %>%
  group_by(GRAD_STAT_DESC, DW_LEVL) %>%
  summarize(n=n()) %>%
  spread(DW_LEVL, n)
#one more for grad status and degree works percentage (to verify degree completion in any uncertain cases)
student_data2 %>%
  group_by(GRAD_STAT_DESC, DW_AUDIT_PCT) %>%
  summarize(n=n()) %>%
  spread(DW_AUDIT_PCT, n)
#mark students who graduated based on grad status, degree works level, and degree works percentage
student_data2 <- student_data2 %>%
  mutate(graduated = if_else(GRAD_STAT_DESC=="Awarded" | DW_LEVL=="G" | DW_AUDIT_PCT=="100", 1,0))
#replace NA's with 0's
student_data2 <- student_data2 %>% 
  replace_na(list(graduated = 0))
#mark students who are inactive/left early based on graduated variable and student status
student_data2 <- student_data2 %>%
  mutate(inactive = if_else(graduated==0 & CUR_STU_STATUS_DESC=="Inactive",1,
                            if_else(CUR_STU_STATUS_DESC=="Leave of Absence"|CUR_STU_STATUS_DESC=="Official Withdrawal", 1,0)))
#replace NA's with 0's
student_data2 <- student_data2 %>% 
  replace_na(list(inactive = 0))
#check crosstab for graduated and inactive to ensure no overlap so far
student_data2 %>%
  group_by(graduated, inactive) %>%
  summarize(n=n()) %>%
  spread(inactive, n)
#mark continuing students based on graduated and inactive
student_data2 <- student_data2 %>%
  mutate(continuing = if_else(graduated==0&inactive==0, 1,0))
#add all three together to make sure no student meets more than one condition
student_data3 <- student_data2 %>%
  mutate(status_check = graduated + inactive + continuing)

#if status check is all 1's, we're good to go!
student_data3 %>%
  count(status_check)
#[thumbs up]
#get a dataframe with id and our 3 new status variables, making sure one row per student
status_data <- student_data3 %>%
  select(Z_NUMBER, graduated, inactive, continuing) %>%
  distinct()

#there appears to be two extra rows... (1302 vs 1300 in course_data)
x <- status_data$Z_NUMBER #get a list of student id's
x[duplicated(x)]          #which ones occur more than once?
status_data %>% filter(Z_NUMBER=="#########")    #let's look at just them, one at a time
status_data %>% filter(Z_NUMBER=="#########")    #(id number intentionally hidden)

#two students must have had a second major but only completed one
#let's remove the rows for their incomplete degrees

status_data <- status_data %>%
  filter(!((Z_NUMBER=="#########"&continuing==1)|
             (Z_NUMBER=="#########"&continuing==1))
         )

#now to join the course data with transfer credits and status variables
full_data <- full_join(courses_tcredits, status_data)
full_data <- ungroup(full_data)
#and add an anonymous id variable
full_data <- full_data %>% mutate(id=rownames(full_data))
#how does it look?
glimpse(full_data)
#one more variable, to combine the 3 separate status variables, for analyses
full_data <- full_data %>%
  mutate(status=if_else(graduated==1, "graduated",
                        if_else(inactive==1, "left early",
                                if_else(continuing==1, "still here", "error"))))
#check for "errors"
full_data %>%
  count(status)
#make a dataframe just to match the real id's to anonymous id's (just in case something goes terribly wrong)
id_match <- full_data %>%
  select(Z_NUMBER, id)
#remove real id from main dataframe
full_data_use <- full_data %>%
  select(-Z_NUMBER)
#lookin good?
glimpse(full_data_use)
#save id key dataframe and full data to use separately
write_csv(id_match, "id_match.csv")
write_csv(full_data_use, "full_data_use.csv")
