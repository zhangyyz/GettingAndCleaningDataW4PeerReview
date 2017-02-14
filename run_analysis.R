#Note: My Environment is RStudio 1.0.136 in Windows 7
#The following pacakges are used in this script and they may need to be installed
#by running the install.packages command:
#  install.packages("data.table")
#  install.packages("memisc")


#Download and unzip the data set
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
              ,destfile = "temp1.zip")
unzip(zipfile="temp1.zip",exdir="dataset")


library(data.table)
#Import the train data into R
xtrain <- fread("dataset/UCI HAR Dataset/train/X_train.txt", header=FALSE)
subjecttrain <- fread("dataset/UCI HAR Dataset/train/subject_train.txt"
                      ,header=FALSE)
ytrain <- fread("dataset/UCI HAR Dataset/train/y_train.txt", header=FALSE)

#Merge subject-train and y-train data into x-train dataset in order to get a
#final train dataset.
traindata <- xtrain[,c("subject","y") := c(subjecttrain[,1], ytrain[,1])]

#Import the test data into R
xtest <- fread("dataset/UCI HAR Dataset/test/X_test.txt", header=FALSE)
subjecttest <- fread("dataset/UCI HAR Dataset/test/subject_test.txt" 
                     ,header=FALSE)
ytest <- fread("dataset/UCI HAR Dataset/test/y_test.txt", header=FALSE)
#Merge subject-train and y-train data into x-train dataset in order to get a
#final test dataset.
testdata <- xtest[,c("subject","y") := c(subjecttest[,1], ytest[,1])]

#Merge the train dataset and test dataset into one dataset
train_test <- rbind(traindata, testdata)

#Import the names for X
xnames <- fread("dataset/UCI HAR Dataset/features.txt", header = FALSE)
xnames <- xnames[,-1] # remove the first column, which is an index column

#Add 'subject' and 'activity' to X names to get a whole list of names
varnames <- rbindlist(list(xnames,list("subject"), list("activity")))

#Set the names for the data set
names(train_test) <- varnames$V2

#Extract features related to only 'mean()' and 'std()'
train_test <- train_test[, grep('std\\(\\)|mean\\(\\)|subject|activity'
                                , colnames(train_test))
                         , with=FALSE]

#For better descriptive purpose, replace activity code with activity labels.
activitylabels <- fread("dataset/UCI HAR Dataset/activity_labels.txt", header = FALSE)
train_test[, activity:=activitylabels$V2[activity]]

#Replace abbreviations with full names for better descriptive purpose.
colnames(train_test)<-gsub("Mag", "Magnitude", colnames(train_test))
colnames(train_test)<-gsub("Acc", "Accelerometer", colnames(train_test))
colnames(train_test)<-gsub("^t", "time", colnames(train_test))
colnames(train_test)<-gsub("Gyro", "Gyroscope", colnames(train_test))
colnames(train_test)<-gsub("^f", "frequency", colnames(train_test))

#Get the average value of each variable for each activity and each subject
newdataset <- train_test[, lapply(.SD, mean), by=list(subject, activity)]

#Save the dataset into a file called 'tidydataset.csv'
write.csv(newdataset, "tidydataset.csv",row.names = FALSE)

#Generate a codebook
library(memisc)
codebook(newdataset)

#Show the date when the script is executed
Sys.time()



