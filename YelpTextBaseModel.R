require("topicmodels")
require(caret)
require(ggplot2)
source("Utility.R")
require("topicmodels")
require("data.table")
require(plyr)
require(rpart)
require(e1071)
# dat_f = YelpSampleReview
data = YelpSampleReview_100 #YelpSampleReview is 100K
str(data)

## Features
data$TotalVotes = data$votes.funny + data$votes.useful + data$votes.cool
data$text = as.character(data$text)
# Create a document matrix 
matrix <- getDtm(data$text)
# Get Sentiment data
sentiment = getSentiment(matrix)
data$pScore = as.numeric(sentiment[, 1])
data$nScore = as.numeric(sentiment[, 2])
data$rScore = as.numeric(sentiment[,3])
data$sentiment = sentiment[, 4]
dr = ddply(data,.(user_id),transform,avgRating = mean(stars))
str(dr)
# $ user_id     : Factor w/ 100 levels "-3JqfrRtS8_NN2fBaK8-vA",..: 1 2 3 4 5 6 7 8 9 10 ...
# $ review_id   : Factor w/ 100 levels "-74fwOuNIrdHpoP3ohVAIw",..: 51 10 14 73 44 40 42 69 32 85 ...
# $ stars       : int  2 5 5 4 3 5 2 5 5 4 ...
# $ date        : Factor w/ 98 levels "2008-01-21","2008-06-26",..: 90 73 97 26 51 63 14 66 79 6 ...
# $ text        : chr  "I got at ...
# $ type        : Factor w/ 1 level "review": 1 1 1 1 1 1 1 1 1 1 ...
# $ business_id : Factor w/ 99 levels "_0kZCkjsGPc1JxOnJguTfA",..: 23 6 7 51 24 96 39 57 14 87 ...
# $ votes.funny : int  0 0 0 0 0 0 2 0 0 3 ...
# $ votes.useful: int  1 0 0 2 0 0 2 0 1 8 ...
# $ votes.cool  : int  0 0 0 1 0 0 1 0 0 7 ...
# $ TotalVotes  : int  1 0 0 3 0 0 5 0 1 18 ...
# $ pScore      : num  148.2 58.1 58.1 132.7 49.6 ...
# $ nScore      : num  90.05 52.55 17.12 53.24 9.48 ...
# $ rScore      : num  1.65 1.1 3.39 2.49 5.24 ...
# $ sentiment   : chr  "positive" "positive" "positive" "positive" ...
# $ avgRating   : num  2 5 5 4 3 5 2 5 5 4 ...
# Examine pos, neg vs. star rating
prop.table(table(dr$stars, dr$sentiment ), 1)
# 
#   negative    neutral   positive
# 1 0.50000000 0.00000000 0.50000000
# 2 0.12500000 0.00000000 0.87500000
# 3 0.07142857 0.14285714 0.78571429
# 4 0.03571429 0.03571429 0.92857143
# 5 0.00000000 0.10869565 0.89130435
lda <- LDA(matrix, method = "Gibbs", control = list(alpha = 0.3), 7)
gammaDF <- as.data.frame(lda@gamma)
names(gammaDF) <- terms(lda)
df <- cbind(dr, gammaDF)

d = df
#scale and center numerical values
d = subset(d, select = -c(user_id,review_id, date, text, type, business_id))
d$sentiment = as.factor(d$sentiment)
d$stars = as.factor(d$stars)
# nums = names(subset(d, select =-c(sentiment, stars)))
# pp = preProcess(d[,nums], method=c("center", "scale"))
# d[,nums] = predict(pp, d[,nums])
#zero variance: None of them
# zerov = nzv(d)
# names(d)[zerov]
## Split data
inTraining = createDataPartition(d$stars, p = .75, list = FALSE)
training = d[ inTraining,]
testing = d[-inTraining,]

#Regression modeling:
#SVM
svm.model <- svm(stars ~ ., data = training, cost = 100, gamma = 1) 
svm.pred <- predict(svm.model, testing[,-1])
confusionMatrix(svm.pred, testing[,1])
#rpart
rpart.model = rpart(stars ~ ., data= training )
rpart.pred = predict(rpart.model, testing[, -1], type = "class")
confusionMatrix(rpart.pred, testing[,1])



