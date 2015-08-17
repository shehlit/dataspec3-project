##Human Activity Recognition Using Smartphones Data Set 

###Introduction
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

More details can be found [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).


####For each record it is provided:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

####The dataset includes the following files:

* 'README.txt'

* 'features_info.txt': Shows information about the variables used on the feature vector.

* 'features.txt': List of all features.

* 'activity_labels.txt': Links the class labels with their activity name.

* 'train/X_train.txt': Training set.

* 'train/y_train.txt': Training labels.

* 'test/X_test.txt': Test set.

* 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

* 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

####Notes: 

- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

### Tasks to be performed by run_analysis.R
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


####Task 1: Create 1 data set
The first thing to do is to read the txt files. The following table summarizes the variables, the txt files read and the assigned column labels:

Variable | Files read | Column Labels
-------- | ---------- | -------------
activity | activity_labels.txt | "Act_ID", "Activity"
feature  | features.txt | --
test_mea | /test/X_test.txt | --
test_act | /test/y_test.txt | "Act_ID"
test_sub | /test/subject_test.txt | "Subject"
train_mea| /train/X_train.txt | --
train_act| /train/y_train.txt | "Act_ID"
train_sub| /train/subject_train.txt | "Subject"

The next step will be combining different data frames.
```{r}
trainc <- cbind(train_sub, train_act, train_mea)
testc <- cbind(test_sub, test_act, test_mea)
whole <- rbind(trainc, testc)
whole <- tbl_df(whole)
```

The variable whole is 1 single data set with all the measurements done on all volunteers.

####Task 2: Extract the required measurements
The required measurements are the mean and standard deviation for each measurement. After checking the labels in features.txt, it is found that the required measurements are found in certain columns. Hence the next step is to extract them using the select function in dplyr package, assign to another variable mean_std.
```{r}
mean_std <- select(whole, Subject, Act_ID, V1:V6, V41:V46, V81:V86, V121:V126, V161:V166, V201:V202, V214:V215, V227:V228, V240:V241, V253:V254, V266:V271, V345:V350, V424:V429, V503:V504, V516:V517, V529:V530, V542:V543) %>%
```

####Task 3: Use actual description of the activities
To perform this task, the following steps are used:

1. Join mean_std and activity with common ID "Act_ID". 
2. Exclude "Act_ID" column and reorder the columns.
3. Arrange mean_std according to Subject and Activity.
4. Use group_by command for calculation of mean in Task 5.

```{r}
 inner_join(activity) %>%
 select(Subject, Activity, V1:V543) %>%
 arrange(Subject, Activity) %>%
 group_by(Subject, Activity)
```

####Task 4: Use descriptive variable names appropriately
To achieve this, the first step is to find the description of the variables from the variable feature.
```{r}
fea_sub <- feature$V2[c(1:6, 41:46, 81:86, 121:126, 161:166, 201:202, 214:215, 227:228, 240:241, 253:254, 266:271, 345:350, 424:429, 503:504, 516:517, 529:530, 542:543)]
```

Fixing some labels in the fea_sub character vector:
```{r}
fea_sub[61:66] <- c("fBodyAccJerkMag-mean()",
                    "fBodyAccJerkMag-std()",
                    "fBodyGyroMag-mean()",
                    "fBodyGyroMag-std()",
                    "fBodyGyroJerkMag-mean()",
                    "fBodyGyroJerkMag-std()")

fea_sub <- gsub("-mean\\()", "Mean", fea_sub)
fea_sub <- gsub("-std\\()", "SD", fea_sub)
fea_sub <- gsub("-", "_", fea_sub)
```
The purpose is to fix the typos in some of the labels and to remove unwanted components in each label. 

The labels are chosen to be similar to the original dataset because it is actually quite clear to users who understand what the measurements are about.

The following table briefly explains what each abbreviation in the label means:


Abbreviation |  Meaning
------------- |  -------------
Body         |  Body
Acc          |  Accelerometer
Gyro         |  Gyroscope
Jerk         |  Jerk
t            |  measurement in time domain 
f            |  measurement in frequency domain Mean         |  Mean / Average
SD           |  Standard Deviation
Mag          |  Magnitude
\_X/Y/Z       |  x/y/z component


The full description of the variables can be found in CodeBook.md.

The last step is then to fix the column names of the data frame.
```{r}
names(mean_std) <- c("Subject", "Activity", fea_sub)
```

####Task 5: Generate a second, independent tidy data set with the average of each variable for each activity and each subject
This can be done easily by using summarise_each and write.table functions.
```{r}
sum_ms <- summarise_each(mean_std, funs(mean), tBodyAccMean_X:fBodyGyroJerkMagSD)
write.table(sum_ms, file = "summary.txt", row.names = FALSE)
```