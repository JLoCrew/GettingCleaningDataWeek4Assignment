# Step 1a - download and unzip file

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("data")){dir.create("data")}
download.file(fileURL, destfile="./data/Train_test_data.zip")

# Step 1b - unzip data
unzip(zipfile = "./data/Train_test_data.zip", exdir = "./data")

# Step 1c - explore the files
# it's always good idea to see what files are in the directory
list.dirs("./data")
list.files("./data/UCI HAR Dataset/test")
list.files("./data/UCI HAR Dataset/train")

# It's always good idea to see the dimensions and first few rows of each data table
firstfewlines <- readLines("./data/UCI HAR Dataset/test/X_test.txt", n=5)
firstfewlines
# looks like the X_ files contain actual data

rm(firstfewlines)
firstfewlines <- readLines("./data/UCI HAR Dataset/test/y_test.txt", n=5)
firstfewlines
# looks like the y_ files contain the activity IDs

rm(firstfewlines)
firstfewlines <- readLines("./data/UCI HAR Dataset/test/subject_test.txt", n=5)
firstfewlines
# looks like the subject_ files contain the subject IDs

rm(firstfewlines)
firstfewlines <- readLines("./data/UCI HAR Dataset/features.txt", n=5)
firstfewlines
# looks like column 2 of the the features.txt file contain the variables names for the X_ files

rm(firstfewlines)
firstfewlines <- readLines("./data/UCI HAR Dataset/activity_labels.txt", n=5)
firstfewlines
# looks like the activity_labels file contain the primary key of activity_ID and the actual description.  
# Recall that the primary keys appear in the y_ files as well

# step 1d - let's read the files
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
# make note that the train files have 7352 observations

x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
# make note that the test files have 2947 observations

# step 1e - let's add the labels
colnames(x_train) <- features[,2]
colnames(y_train) <- "ActivityID"
colnames(subject_train) <- "SubjectID"
colnames(x_test) <- features[,2]
colnames(y_test) <- "ActivityID"
colnames(subject_test) <- "SubjectID"



#let's combine the columns of the test and train files first
cbind_test <- cbind(y_test, subject_test, x_test)
cbind_train <- cbind(y_train, subject_train, x_train)
# cbind_test still has 2947 rows; cbind_train still has 7352 rows, and 563 variables each which is good

# step 1f - let's combine the rows of the new test and train files
rbind_test_train <- rbind(cbind_test, cbind_train)
# rbind_test_train now has 10299 rows and 563 variables which is correct

# Step 2 - keep the mean and std dev attributes
# read the column headings
names(rbind_test_train)
df <- rbind_test_train[,grepl("-mean()", colnames(rbind_test_train))| grepl("-std()", colnames(rbind_test_train))| grepl("ActivityID", colnames(rbind_test_train))| grepl("SubjectID", colnames(rbind_test_train))]
head(df,3)

# Step 3 - using Activity ID as the primary key, look up the Activity Type
# first, we need to read the Activity Labels table and assign column headings
Activitylabels <- read.table('./data/UCI HAR Dataset/activity_labels.txt')
colnames(Activitylabels) <- c("ActivityId", "ActivityType")
Big_df <- merge(df[,1:81], Activitylabels[,1:2], by=1, all.x = TRUE)

# Step 4 - calculate mean by variable by ActivityType and by SubjectID
# we can use cast and melt functions
install.packages("reshape")
library(reshape)
New_big_df <- melt(Big_df, id=c("SubjectID", "ActivityID", "ActivityType"))
Casted_New_big_df <- cast(New_big_df, SubjectID + ActivityID + ActivityType ~ variable, mean)

# Step 5 - write this new table as a second data set
write.table(Casted_New_big_df, "SecondTidy.txt", row.name=FALSE)
















