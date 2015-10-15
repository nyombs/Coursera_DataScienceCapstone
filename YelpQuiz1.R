library(jsonlite)
rFile = "yelp_academic_dataset_review.json"
dat <- fromJSON(sprintf("[%s]", paste(readLines(rFile), collapse=",")), flatten = TRUE)
data = dat
dim(data)
data[100, ]
prop.table(table(data$stars == 5))

bFile = "yelp_academic_dataset_business.json"
bData <- fromJSON(sprintf("[%s]", paste(readLines(bFile), collapse=",")), flatten = TRUE)
dim(bData)
str(bData)
names(bData)
prop.table(table(bData[!is.na(bData["attributes.Wi-Fi"]), ]["attributes.Wi-Fi"] == "free"))

tFile= "yelp_academic_dataset_tip.json"
tData <- fromJSON(sprintf("[%s]", paste(readLines(tFile), collapse=",")), flatten = TRUE)
dim(tData)
str(data)
#x = by(dat, dat$votes.funny, sum)

# group A sum all Bs
x = aggregate(votes.funny ~ user_id, data, length)


uFile = "yelp_academic_dataset_user.json"
uData <- fromJSON(sprintf("[%s]", paste(readLines(uFile), collapse=",")), flatten = TRUE)
x = aggregate(compliments.funny ~ name, uData, sum)
nD = uData[!is.na(uData$compliments.funny), ]
nD[nD$compliments.funny > 10000, ]$name

summary(uData$fans)
lData = uData
lData$compliments.funny = ifelse(is.na(lData$compliments.funny), 0, lData$compliments.funny)
lData$fans = ifelse(is.na(lData$fans), 0, lData$fans)
summary(uData$fans)

t = table(lData$fans > 1, lData$compliments.funny > 1)
t
fisher.test(t)
