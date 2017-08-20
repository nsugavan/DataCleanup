library(httr)
library(plyr)
library(curl)
# Download and unzip dataset

 fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

 download.file(fileURL, "datafile.zip", method = "curl")

 unzip("datafile.zip", exdir = "./")


# Read the subject files and merge them.
subjecttest <- read.table("./UCI HAR Dataset/test/subject_test.txt",header = F, stringsAsFactors = F, fill = T, col.names = c("Subject"))
subjecttrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = F, stringsAsFactors = F, fill = T,col.names = c("Subject"))
subject <- rbind(subjecttest,subjecttrain)

# Read the activity lable, activity file and merge them
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt", header = F, stringsAsFactors = F, fill = T, col.names=c("Code","Name"))

ytest <- read.table("./UCI HAR Dataset/test/y_test.txt",header = F, stringsAsFactors = F, fill = T,col.names = c("Activity"))
ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt",header = F, stringsAsFactors = F, fill = T,col.names = c("Activity"))
yMerge <- rbind(ytest,ytrain)

# Cross walk activity code with activity name
yMerge$Activity <- factor(yMerge$Activity, levels = activity_labels[,"Code"], labels = activity_labels[,"Name"])

# Read Feature file for column names
features <- read.table("./UCI HAR Dataset/features.txt", header = F, stringsAsFactors = F, fill = T,col.names=c("num","Name"))

xtest <- read.table("./UCI HAR Dataset/test/X_test.txt",header = F, stringsAsFactors = F, fill = T,col.name=features[,"Name"])
xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt",header = F, stringsAsFactors = F, fill = T,col.name=features[,"Name"])

xMerge <- rbind(xtest,xtrain)

# Selecting only required column
xMerge <- xMerge[, grepl("mean()|std()", colnames(xMerge)) & !grepl("meanFreq", colnames(xMerge))]

# Combining all the columns
finalData <- cbind(subject,yMerge,xMerge)

# Creating Tidy Data Set with mean of each column

tidyDataSet <- ddply(finalData,.(Subject,Activity),.fun=function(x){colMeans(x[,-c(1:2)])})

# Write the file

write.csv(tidyDataSet, "./tidyDataSet.txt", row.names = FALSE)

