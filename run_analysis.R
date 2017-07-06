require("data.table")
require("reshape2")

# Load activity labels to variable al
al <- read.table("./UCI_HAR_Dataset/activity_labels.txt")
al <- al[,2]

# Load fetures data names to variable name fs
fs <- read.table("./UCI_HAR_Dataset/features.txt")
fs <- fs[,2]

# Extract the mean and standard deviation for each measurement.
mean_std_header <- grepl("mean|std", fs)

# Load X_test & y_test data.
X_test<- read.table("./UCI_HAR_Dataset/test/X_test.txt")
y_test <- read.table("./UCI_HAR_Dataset/test/y_test.txt")
subject<- read.table("./UCI_HAR_Dataset/test/subject_test.txt")

# Set Names for X_test
names(X_test)<-fs

# Extract the mean and standard deviation.
X_test<-X_test[,mean_std_header]

# Load activity labels
y_test[,2]<-al[y_test[,1]]
names(y_test)<-c("Activity_ID", "Activity_Label")
names(subject)<-"subject"

# Bind data
test_data <- cbind(as.data.table(subject), y_test, X_test)

# Load and process X_train & y_train data.
X_train <- read.table("./UCI_HAR_Dataset/train/X_train.txt")
y_train <- read.table("./UCI_HAR_Dataset/train/y_train.txt")

subject_train <- read.table("./UCI_HAR_Dataset/train/subject_train.txt")

names(X_train)<-fs

# Extract only the measurements on the mean and standard deviation for each measurement.
X_train = X_train[,mean_std_header]

# Load activity data
y_train[,2]<-al[y_train[,1]]

names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

# Bind y_train, X_train data
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Merge test and train data
data = rbind(test_data, train_data)

id_labels   = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "./tidy_data.txt")
