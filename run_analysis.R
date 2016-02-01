# Assignment: Getting and Cleaning Data - week 4
# 
# Prerequisite, data should be downloaded from:
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
# And extracted in the same directory as this file.

# Load required packages
library("data.table")
getwd()

# set some constants / defaults
datadir <- "UCI HAR Dataset"
testdatadir <- paste(datadir, "test", sep="/")
traindatadir <- paste(datadir, "train", sep="/")

# load common data
activity_labels <- read.table(paste(datadir, "activity_labels.txt", sep="/"))
features <- read.table(paste(datadir, "features.txt", sep="/"))

# load test data
subject_test <- read.table(paste(testdatadir, "subject_test.txt", sep="/")) 
X_test <- read.table(paste(testdatadir, "X_test.txt", sep="/")) 
y_test <- read.table(paste(testdatadir, "y_test.txt", sep="/")) 

# load train data
subject_train <- read.table(paste(traindatadir, "subject_train.txt", sep="/")) 
X_train <- read.table(paste(traindatadir, "X_train.txt", sep="/")) 
y_train <- read.table(paste(traindatadir, "y_train.txt", sep="/"))

# name columns
## subject
names(subject_test) <- "subject_id"
names(subject_train) <- "subject_id"

## X
names(X_train) <- features$V2
names(X_test) <- features$V2

## Y
names(y_train) <- c("activity")
names(y_test) <- c("activity")

# combine files into one dataset
## training
train <- cbind(subject_train, y_train, X_train)
# dim = 7352 563

## test
test <- cbind(subject_test, y_test, X_test)
# dim = 2947 563

# 1. Merge the training and the test sets to create one data set.
dataset <- rbind(train,test)
# dim = 10299 563

# 2. Extract only the measurements on the mean and standard deviation for each measurement.
# these measurement labels end with mean() or std().
meanstdcols <- grepl("mean\\(\\)$|std\\(\\)$", names(dataset))
# Don't forget to keep the first two columns
keepcols <- meanstdcols
keepcols[1:2] <- TRUE

meanstd_data <- dataset[, keepcols]
# dim = 10299 20

# 3. Use descriptive activity names to name the activities in the data set
meanstd_data$activity <- activity_labels$V2[meanstd_data$activity]

# 4. Appropriately label the data set with descriptive variable names.
# This was done in the "# name columns" step.

# 5. From the data set in step 4, create a second, independent tidy data set with 
# the average of each variable for each activity.
meanstd_data_summary <- aggregate(
                            meanstd_data[, 3:dim(meanstd_data)[2]],
                            list(meanstd_data$activity),
                            mean
                        )
# rename first column name to activity.
names(meanstd_data_summary)[1] <- c('activity')

# Store the dataset
write.table(meanstd_data_summary, "tidy_data_chris.txt", row.name=FALSE)
