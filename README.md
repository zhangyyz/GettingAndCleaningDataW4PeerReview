#Steps performed in my script (Note: My Environment is RStudio 1.0.136 in Windows 7)

###Step 1: The following pacakges are used in this script and they may need to be installed by running the install.packages command:
```
install.packages("data.table")
install.packages("memisc")
```
###Step 2: Download and unzip the data set
```
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
              ,destfile = "temp1.zip")
unzip(zipfile="temp1.zip",exdir="dataset")
```
###Step 3: Import the train data into R
```
library(data.table)
xtrain <- fread("dataset/UCI HAR Dataset/train/X_train.txt", header=FALSE)
subjecttrain <- fread("dataset/UCI HAR Dataset/train/subject_train.txt"
                      ,header=FALSE)
ytrain <- fread("dataset/UCI HAR Dataset/train/y_train.txt", header=FALSE)
```
###Step 4: Merge subject-train and y-train data into x-train dataset in order to get a complete train dataset.
```
traindata <- xtrain[,c("subject","y") := c(subjecttrain[,1], ytrain[,1])]
```
###Step 5: Import the test data into R
```
xtest <- fread("dataset/UCI HAR Dataset/test/X_test.txt", header=FALSE)
subjecttest <- fread("dataset/UCI HAR Dataset/test/subject_test.txt" 
                     ,header=FALSE)
ytest <- fread("dataset/UCI HAR Dataset/test/y_test.txt", header=FALSE)
```
###Step 6: Merge subject-train and y-train data into x-train dataset in order to get a complete test dataset.
```
testdata <- xtest[,c("subject","y") := c(subjecttest[,1], ytest[,1])]
```
###Step 7: Merge the train dataset and test dataset into one dataset
```
train_test <- rbind(traindata, testdata)
```
###Step 8: Import the names for X
```
xnames <- fread("dataset/UCI HAR Dataset/features.txt", header = FALSE)
xnames <- xnames[,-1] # remove the first column, which is an index column
```
###Step 9: Add 'subject' and 'activity' to X names to get the complete list of names
```
varnames <- rbindlist(list(xnames,list("subject"), list("activity")))
#Set the names for the data set
names(train_test) <- varnames$V2
```
###Step 10: Extract features related to only 'mean()' and 'std()'
```
train_test <- train_test[, grep('std\\(\\)|mean\\(\\)|subject|activity'
                                , colnames(train_test))
                         , with=FALSE]
```
###Step 11: For better descriptive purpose, replace activity code with activity labels.
```
activitylabels <- fread("dataset/UCI HAR Dataset/activity_labels.txt", header = FALSE)
train_test[, activity:=activitylabels$V2[activity]]
```
###Step 12: For better descriptive purpose, replace abbreviations with full names .
```
colnames(train_test)<-gsub("Mag", "Magnitude", colnames(train_test))
colnames(train_test)<-gsub("Acc", "Accelerometer", colnames(train_test))
colnames(train_test)<-gsub("^t", "time", colnames(train_test))
colnames(train_test)<-gsub("Gyro", "Gyroscope", colnames(train_test))
colnames(train_test)<-gsub("^f", "frequency", colnames(train_test))
```

###Step 13: For better descriptive purpose, remove brackets "(" and ")" from names
colnames(train_test)<-gsub("\\(|\\)", "", colnames(train_test))

###Step 14: Get the average value of each variable for each activity and each subject
```
newdataset <- train_test[, lapply(.SD, mean), by=list(subject, activity)]
```
###Step 15: Save the dataset into a file called 'tidydataset.txt'
```
write.table(newdataset, "tidydataset.txt",row.names = FALSE, sep=",")
```
###Step 16: Generate a codebook
```
library(memisc)
Write(codebook(newdataset), file = "codebook.txt")
```
###Step 17: Show the date when the script is executed
```
Sys.time()
```


