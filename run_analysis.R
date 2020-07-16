library(dplyr)

#Merge the training and test datasets

x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")

x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

features <- read.table("UCI HAR Dataset/features.txt")

activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")

colnames(x_train) <- features[,2]
colnames(y_train) <- "activityID"
colnames(subject_train) <- "subjectID"

colnames(x_test) <- features[,2]
colnames(y_test) <- "activityID"
colnames(subject_test) <- "subjectID"

colnames(activityLabels) <- c("activityID", "activityType")

alltrain <- cbind(y_train, subject_train, x_train)
alltest <- cbind(y_test, subject_test, x_test)
finaldataset <- rbind(alltrain, alltest)

#Extracting only the measurements on the mean and sd for each measurement

colNames <- colnames(finaldataset)

mean_and_std <- (grepl("activityID", colNames) |
                   grepl("subjectID", colNames) |
                   grepl("mean..", colNames) |
                   grepl("std...", colNames))

setforMeanandStd <- finaldataset[ , mean_and_std == TRUE]

#Use descriptive activity names
setWithActivityNames <- merge(setforMeanandStd, activityLabels,
                              by = "activityID",
                              all.x = TRUE)

#Label the data set with descriptive variable names
names(setWithActivityNames) <- gsub("Acc", "Accelerometer", names(setWithActivityNames))

names(setWithActivityNames) <- gsub("Gyro", "Gyroscope", names(setWithActivityNames))

names(setWithActivityNames) <- gsub("BodyBody", "Body", names(setWithActivityNames))

names(setWithActivityNames) <- gsub("^t", "Time", names(setWithActivityNames))

names(setWithActivityNames) <- gsub("Mag", "Magnitude", names(setWithActivityNames))

names(setWithActivityNames) <- gsub("^f", "Frequency", names(setWithActivityNames))

names(setWithActivityNames) <- gsub("-std", "STD", names(setWithActivityNames),
                                    ignore.case = TRUE)

names(setWithActivityNames) <- gsub("-mean", "Mean", names(setWithActivityNames),
                                    ignore.case = TRUE)


#Creating a second,  independent tidy data set with the avg of each variable for each activity and subject

tidySet <- aggregate(. ~subjectID + activityID, setWithActivityNames, mean)
tidySet <- tidySet[order(tidySet$subjectID, tidySet$activityID), ]

write.table(tidySet, "tidySet.txt", row.names = FALSE)
