## run_analysis.R

## Load libraries
library(dplyr)

## Read files
train_mea <- read.table("./train/X_train.txt", stringsAsFactors = FALSE)
train_act <- read.table("./train/y_train.txt", stringsAsFactors = FALSE)
train_sub <- read.table("./train/subject_train.txt", stringsAsFactors = FALSE)
test_mea <- read.table("./test/X_test.txt", stringsAsFactors = FALSE)
test_act <- read.table("./test/y_test.txt", stringsAsFactors = FALSE)
test_sub <- read.table("./test/subject_test.txt", stringsAsFactors = FALSE)
activity <- read.table("activity_labels.txt", stringsAsFactors = FALSE)
features <- read.table("features.txt", stringsAsFactors = FALSE)

## Assign Column Names
names(train_act) <- "Act_ID"
names(train_sub) <- "Subject"
names(test_act) <- "Act_ID"
names(test_sub) <- "Subject"
names(activity) <- c("Act_ID", "Activity")

## Merge files
trainc <- cbind(train_sub, train_act, train_mea)
testc <- cbind(test_sub, test_act, test_mea)
whole <- rbind(trainc, testc)
whole <- tbl_df(whole)

## Extract mean and sd of measurements 
mean_std <- select(whole, Subject, Act_ID, V1:V6, V41:V46,
                   V81:V86, V121:V126, V161:V166, V201:V202,
                   V214:V215, V227:V228, V240:V241, V253:V254,
                   V266:V271, V345:V350, V424:V429, V503:V504,
                   V516:V517, V529:V530, V542:V543) %>%

## Naming activities in data set
 inner_join(activity) %>%
 select(Subject, Activity, V1:V543) %>%
  
## Arrange and group_by
  arrange(Subject, Activity) %>%
  group_by(Subject, Activity)

## Summary of average of each variable for each activity
## and each subject
sum_ms <- summarise_each(mean_std, funs(mean), V1:V543)

## Generate table
write.table(sum_ms, file = "summary.txt", row.names = FALSE)
