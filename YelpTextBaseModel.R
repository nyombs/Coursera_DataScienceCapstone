require("topicmodels")
require(caret)
source("Utility.R")
require("topicmodels")
require("data.table")
# dat_f = YelpSampleReview
data = YelpSampleReview_100 #YelpSampleReview is 100K
str(data)
data$TotalVotes = data$votes.funny + data$votes.useful + data$votes.cool
data$text = as.character(data$text)
# Create a document matrix 
matrix <- getDtm(data$text)
# Get Sentiment data
sentiment = getSentiment(matrix)
dt <- data.table(data)
content = dt[, paste(text,collapse=" "),by=stars]
content1 = dt[stars == 1]

data$Sentiment = ifelse(classify.naivebayes(data$text)[1, 4] == "positive", 1, 0)
data$outcome = ifelse(data$stars >= 4, 1, 0)
confusionMatrix(data$Sentiment, data$outcome)

for(i in 1:100)data[i,]$Topics=terms(LDA(create_matrix(cbind(data[i, ]$text), 
                                                     language="english", 
                                                     removeNumbers=TRUE, 
                                                     stemWords=FALSE, weighting=tm::weightTf), 3))

data$Topics <- terms(LDA(create_matrix(cbind(data$text), 
                            language="english", 
                            removeNumbers=TRUE, 
                            stemWords=FALSE, weighting=tm::weightTf), 100))


str(data$Topic)



