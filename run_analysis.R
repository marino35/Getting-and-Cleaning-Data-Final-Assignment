#Loading the library dplyr
library(dplyr)

#Creating the destination File
file <- "GACD_Final_Project.zip"

#Download the file if the file does not exist
if (!file.exists(file)) {
    file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(file_url, file, method = "curl")
}

#Check if the file is already unzipped
if (!file.exists("UCI HAR Dataset")) { 
  unzip(file) 
}

#Reading files from the folders
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

#1 - Merge the training and test sets
X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
MergedFiles <- cbind(Subject, Y, X)

#2 - Extract only the measurements on the mean and standard deviation for each measurement
GoodFile <- MergedFiles %>% select(subject, code, contains("mean"), contains("std"))

#3 - Uses descriptive activity names to name the activities in the data set
GoodFile$code <- activities[GoodFile$code, 2]

#4 - Appropriately labels the data set with descriptive variable names
names(GoodFile)[2] = "activity"
names(GoodFile)<-gsub("Acc", "Accelerometer", names(GoodFile))
names(GoodFile)<-gsub("Gyro", "Gyroscope", names(GoodFile))
names(GoodFile)<-gsub("BodyBody", "Body", names(GoodFile))
names(GoodFile)<-gsub("Mag", "Magnitude", names(GoodFile))
names(GoodFile)<-gsub("^t", "Time", names(GoodFile))
names(GoodFile)<-gsub("^f", "Frequency", names(GoodFile))
names(GoodFile)<-gsub("tBody", "TimeBody", names(GoodFile))
names(GoodFile)<-gsub("-mean()", "Mean", names(GoodFile), ignore.case = TRUE)
names(GoodFile)<-gsub("-std()", "STD", names(GoodFile), ignore.case = TRUE)
names(GoodFile)<-gsub("-freq()", "Frequency", names(GoodFile), ignore.case = TRUE)
names(GoodFile)<-gsub("angle", "Angle", names(GoodFile))
names(GoodFile)<-gsub("gravity", "Gravity", names(GoodFile))

#5 - From the data set in step 4, creates a second, independent tidy data det with the average of each variable for each activity and each subject
FinalFile <- GoodFile %>%
  group_by(subject, activity) %>%
  summarize_all(funs(mean))
write.table(FinalFile, "FinalFile.txt", row.name=FALSE)
