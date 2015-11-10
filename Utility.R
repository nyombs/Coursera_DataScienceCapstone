require('tm')

## Helper functions

## Return document matrix by first cleaning up text
getDtm <- function(sentences, language="english", 
                         minDocFreq = 1, minWordLength = 4, 
                         removeNumbers = TRUE, removePunctuation = TRUE, 
                         removeStopwords = TRUE, 
                         stemWords = FALSE, stripWhitespace = TRUE, 
                         toLower = TRUE, weighting = weightTf) {
  

  control <- list(language = language, tolower = toLower,
                  removeNumbers = removeNumbers, removePunctuation = removePunctuation,
                  stripWhitespace = stripWhitespace, minWordLength = minWordLength,
                  stopwords = removeStopwords, minDocFreq = minDocFreq, 
                  weighting = weighting)
  
  if (stemWords == TRUE)
    control <- append(control, list(stemming = process.stemwords), after=6)
  
  content <- apply(as.matrix(sentences), 1, paste, collapse=" ")
  content <- sapply(as.vector(content, mode="character"),
                  iconv, to="UTF8", sub="byte")
  
  corpus <- Corpus(VectorSource(content), readerControl=list(language=language))
  matrix <- DocumentTermMatrix(corpus,control=control)
  gc() # garbage collect
  return(matrix)
}

getSentiment <- function(matrix) {
  
  pstrong=0.5
  pweak=1.0 
  prior=1.0
  
  lexicon <- read.csv("subjectivity.csv", head = FALSE)
  
  counts <- list(positive = length(which(lexicon[,3]=="positive")), 
                 negative = length(which(lexicon[,3]=="negative")),
                 total = nrow(lexicon))
  
  documents <- c()
  
  for (i in 1:nrow(matrix)) {
    scores <- list(positive=0, negative=0)
    doc <- matrix[i,]
    words <- findFreqTerms(doc, lowfreq=1) ## find the words that are the most frequent
    
    for (word in words) {
      index <- pmatch(word,lexicon[,1],nomatch=0)
      if (index > 0) { # if we have a match with our dictionary
        entry <- lexicon[index,]
        
        polarity <- as.character(entry[[2]])
        category <- as.character(entry[[3]])
        count <- counts[[category]]
        
        score <- pweak
        if (polarity == "strongsubj") score <- pstrong
        score <- abs(log(score*prior/count))
        scores[[category]] <- scores[[category]]+score
      }		
    }
    
    for (key in names(scores)) {
      count <- counts[[key]]
      total <- counts[["total"]]
      score <- abs(log(count/total))
      scores[[key]] <- scores[[key]]+score
    }
    
    best_fit <- names(scores)[which.max(unlist(scores))]
    
    ratio <- abs(scores$positive/scores$negative)
    
    if (ratio > 0.90 && ratio < 1.10)
      best_fit <- "neutral"
    
    documents <- rbind(documents,c(scores$positive,scores$negative,abs(scores$positive/scores$negative),best_fit))
  }
  return (documents)
}