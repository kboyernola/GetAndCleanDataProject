# Assumes working directory is set and that the data files below are present in it
# Note that there are two sub-directories, test and train, each with their own set of files

# Load the plyr library so the ddply() function is available
library(plyr)

# Read in data
activity_labels <- read.table("activity_labels.txt")
features <- read.table("features.txt")
subject_test <- read.table("./test/subject_test.txt")
y_test <- read.table("./test/y_test.txt")
x_test <- read.table("./test/x_test.txt")
subject_train <- read.table("./train/subject_train.txt")
y_train <- read.table("./train/y_train.txt")
x_train <- read.table("./train/x_train.txt")

# Merge test and train
subjects <- rbind(subject_test,subject_train)
y_data <- rbind(y_test,y_train)
x_data <- rbind(x_test,x_train)

# Activity labels need to be added as a column to x_data, so we will use
# merge() to add the activity_labels to the vector of activities (y_data)
# to get a data frame of activity code and activity labels (activity).
# However, the merge() function re-orders that data, meaning that the resulting
# Activity data frame and the feature vector rows in x_data will be
# mis-matched.
# Add a row number column to y_data to so you can restore
# the original order after applying the merge() function
y_data$Row_No <- 1:nrow(y_data) 
 
# Create an activity dataframe with Row_No, activity codes and activity labels
activity <- merge(y_data, activity_labels, by="V1")

# Restore the original row order
activity <- activity[order(activity$Row_No),] 
 
# Change column names for x_data
colnames(x_data) <- as.factor(features[[2]])

# Add the subjects and activity labels to the x_data 
 x_data$Activity <-  activity$V2
 x_data$Subject <- subjects$V1
 
 
# Identify all the column names with "mean" and "std" (standard deviation)
meanCols <- grep("mean",names(x_data))
stdCols <- grep("std",names(x_data))

# Subset the data frame to include Activity, Subject and the mean and std columns
mean_std_data <- x_data[, c(562:563,meanCols,stdCols)]


 
# Create tidy data set
# 	Tidy data criteria:
#	o Each variable is found in one and only one column
#	o Each observation is found in one and only one row
#	o Each type of observational unit is found in one and only one table
# Thanks to mage's blog
# http://www.magesblog.com/2012/01/say-it-in-r-with-by-apply-and-friends.html
# for pattern. 

 tidy_data <-ddply(mean_std_data, c("Activity","Subject"), colwise(mean)) 
 
# Write tidy_data out to a text file in the working directory
write.table(tidy_data,"tidy_data.txt",row.name=FALSE)
 
# Clean up
# Unload the plyr library
detach("package:plyr")

# Remove all the objects from memory
rm("activity","activity_labels","features","mean_std_data","meanCols","stdCols","subject_test","subject_train","subjects","x_data","x_test","x_train","y_data","y_test","y_train")

   
 