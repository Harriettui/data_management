### BES R course on data management - 23rd May 2016 ##

# Document everythng you do with your data - reproduceability 
# each data point should have unique identifier (e.g. ID number)
# data should be in a repository - DOI often requested by journals
# using git to store code


## PART 1 - utilising data from multiple data sources 

# avoid changing the original datasets, if you do create a new dataset version. Keep a note of all changes

## reading in datasets other than "read.csv" - use the "xlsx" package and read.xlsx("file",sheetName) - this brings in everything
# from the csv file so exact numbers are loaded, i.e. its more precise 1.234567 vs 1.234

# relational dataset, e.g. access - unique row identifiers - relates different tables to one another

# existing databases can be accessed directly using computers ODBC driver and the RODBC package
# important to ensure 32-bit/64-bit continuity betwee driver

# RODBC wont work on MAC so alternative way to read in access database

# install 'homebrew' and then the package "hmisc" should work
install.packages("xlsx")
install.package("hmisc")
sessionInfo()

brew install mdbtools
mdb.get("DM_2305_AccessExample.accdb")


## using R for spatial data
# lots of packages are available for integrating spatial analyses into R-based workflow, 
# e.g. "rdgal", "rgeos"
# however python is much faster than R - better for bigger GIS jobs, like clipping large number
# shapefiles


# PART 2 - Manipulating data in R

# Tidy Data paper - in the "tidyr" package

iris <- iris
is.data.frame(iris)
is.matrix(iris)
typeof(iris)
iris.mat <- as.matrix(iris)
iris.list <- as.list(iris)

iris$Plot <- rep(c(rep(1,10), rep(2, 10), rep(3,5)),3)
lm1 <- lm(Sepal.Length ~ Species + Plot, data = iris)
summary(lm1)
## change Plot to a factor
is.factor(iris$Plot) #check if this is a factor
iris$Plotf <- factor(iris$Plot) #change to factor
is.factor(iris$Plotf) #check it changed

str(iris.list)
iris.list$Sepal.Length
iris.list[1]
iris.list[[1]]
iris.list[[1]][1]

## sorting data in R

iris[order(iris$Petal.Width),] #order data with narrow petals first
iris[order(-iris$Petal.Width),] # or wide petals first
iris[order(iris$Species, iris$Petal.Width),] #or by species then petal width

duplicated(iris) #checking for duplicates
duplicated(iris[,3:4]) #to check for unique records where petal length and petal width are unique
duplicated(iris[,3:4])[1:6] #first six results of duplicated
head(iris,6)#first six rows of the dataset
# tells us rows 2 and 5 are duplicated
# to remove the duplicates:
iris.unique <- iris[!duplicated(iris[,3:4]),] #The exclamation marks means 'not'
nrow(iris.unique) #102 rows remain in this dataset from the 150 original rows
# same can be achieved using the dplyr package
library(dplyr)
iris.unique2 <- distinct(iris, Petal.Length, Petal.Width)
nrow(iris.unique2)

# Removing missing data
iris.NA <- iris
iris.NA[1:4,1] <- NA #replace the first four entries in column 1 with NA
head(iris.NA)
summary(iris.NA) #identify which columns have NAs
iris.NA[is.na(iris.NA$Sepal.Length),] #display rows with NAs
iris.NA.cc <- iris.NA[complete.cases(iris.NA),]
head(iris.NA.cc)
summary(iris.NA.cc)

## Reshaping data

#data should be in the following format:
#1. Each variable is a column

#2. Each observation is a row

#3. Each type of observational unit forms a table

# "tidyr" package helps to do this, as does "reshape" which is more flexible

library(reshape2)
# There are 2 functions - melt and cast
# melt changes format from wide to long - so you get all values in one column with labels

iris.melt <- melt(iris)
summary(iris.melt)

#cast is the opposite - changes long to wide format
# can use it to calculate mean of a variable/s for each species for example
iris.cast2 <- dcast(iris.melt, Species~variable, fun=mean)
iris.cast2

# Summarising data - two popular approach for summarising your data are 'apply' and 'aggregate'
iris.agg <- aggregate(iris,list(iris$Species),mean)

tapply(iris$Sepal.Length,iris$Species,mean) #only works on single column at a time

#### Applying functions
#R is (very handily) vectorized which means it is very simple to calculate functions for each 
#row of a dataset/entry in a vector. Import datasets and run calculations in R

#create a new column
iris$LogSepLength <- log(iris$Sepal.Length)



# NB - ## interogating a dataset - PREDICTS examples
predicts <- read.csv("http://onlinelibrary.wiley.com/store/10.1002/ece3.1303/asset/supinfo/ece31303-sup-0002-DataS1.csv?v=1&s=f1c0f0c5a047aa08c65fb48a3186cecc18faa8a0")
predicts <- tbl_df(predicts)  # convert to tbl_df

# INVESTIGATE
# how many names?
length(names(predicts))
# how many columns?
ncol(predicts)
# print, don't worry dplyr won't spend hours printing!
print(predicts)

# HOW HABITATS ARE REPRESENTED BY EACH STUDY?

# Method 1: for loop
# Identify the studies by creating a new studies column
predicts$SSID <- paste0(predicts$Source_ID, '_', predicts$Study_number)
stds <- unique(predicts$SSID)
# Loop through and identify the the number of habitats in each study
nhabitats <- rep(0, length(stds))
for(i in 1:length(nhabitats)) {
  nhabitats[i] <- length(unique(predicts$Predominant_habitat[predicts$SSID == stds[i]]))
}
res_1 <- data.frame(stds, nhabitats)
res_1

## split, apply, combine approach "group by"
# Method 2: group_by + summarise
# group
res_2 <- group_by(predicts, SSID)
# summarise
res_2 <- summarise(res_2, N_habitats=n_distinct(Predominant_habitat))
## takes each group and runs operation on them - i.e. above creating N_habitats

# Method 3: Behold, the power of the pipe!
# piping %>% 
res_3 <- mutate(predicts, SSID=paste0(Source_ID, '_', Study_number)) %>%
  group_by(SSID) %>%
  summarise(N_habitats=n_distinct(Predominant_habitat))

# swirl package - tutorials for "dplyr" and "tidyr"


### Part 2.2. MULTIPLE DATASETS #

# you might store data in more than one dataset and want to join data
#create some data for plot 4
iris.extra <- data.frame(Sepal.Length = rnorm(10, 5, 0.7), Sepal.Width = rnorm(10,3.2,0.5),Petal.Length = rnorm(10,1.3,0.3), Petal.Width = rnorm(10,0.2, 0.001), Species = "setosa", Plot = 4)
rbind(iris, iris.extra) #function of R that appends datasets, however it needs correct number columns
#so have to add extra columns to the new data
iris.extra$Plotf <- factor(iris.extra$Plot)
iris.extra$LogSepLength <- log(iris.extra$Sepal.Length)
iris.all <- rbind(iris, iris.extra)

# 2.2.2. Matching data
# you can also link datasets through a common value or attribute, e.g. with LPI this could be ID
# this requires a unique and persistent identifier
# set this UPI for the Iris dataset
iris.all$ObsID <- paste0(iris.all$Species, row.names(iris.all))
# create the two additional datasets - species data and plant data
irisspdata <- data.frame(Species = unique(iris$Species), avgheight = c(42.3, 33.5, 35.7), colour = c("violet", "blue", "blue"))
irisindivdata <- data.frame(ObsID = iris.all$ObsID, noseeds = c(rpois(50, 10), rpois(50,8), rpois(50, 9), rpois(10,10)))
irisindivdata$germprop <- c(rpois(50, 3), rpois(50,2), rpois(50, 3), rpois(10,3))/irisindivdata$noseeds

# use 'sqldf' function to match the datasets - SQL type queries
library(sqldf)
# Joining the species data is straightforward BUT . means something different in SQL so I first need to rename iris.all as iris_all
iris_all <- iris.all
irismatchsp <- sqldf("select * from iris_all, irisspdata where iris_all.Species = irisspdata.Species")
#The * indicate we want all columns from both datasets in the new dataset.
#Now we can add the other species data
irismatchindiv <- sqldf("select * from irismatchsp, irisindivdata where irismatchsp.ObsID = irisindivdata.ObsID")
# this causes an issue because we have duplicate column names "species"
# just select the required columns:
irismatchsp2 <- sqldf("select t1.*, t2.avgheight, t2.colour from iris_all as t1, irisspdata as t2 where t1.Species = t2.Species")
irismatchindiv <- sqldf("select * from irismatchsp2, irisindivdata where irismatchsp2.ObsID = irisindivdata.ObsID")
head(irismatchindiv)


### PART 3 - DOCUMENTATION #

## documentation correctly of data management and analysis is important for Quality Assurance
# know what your R scripts do and what order they need to be run in - make a comment at the top of a script
# i.e. the author, when it was created and any edits made on certain dates
# use RMarkdown - allows you to write comments/text plus the code in the same place which can then be saved as HTML or word doc
# use source() in scripts to call previous scripts
# document workflow in a readme file
# Version control on R script helps to figure out why you might get different results etc. but can cause problems if you have too many - documnent what you changed!
# Git - really useful for version control of R script - tracks the changes for you - perfect for collaboration

## setting up Git repository on R Studio opens up a new tab in the environment pane
# Tools -> Version Control