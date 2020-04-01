library(data.table)

source("PrepareData.R")

#### Exploration with "stylo" GUI ####

styloResult <- stylo::stylo(path = "data")
summary(styloResult)

#### Manual analysis ####

### Pre-processing
# Load and tokenize, make ngrams
corpus = stylo::load.corpus.and.parse(corpus.dir = "data/corpus", ngram.size = 1)
# Summarize document lengths
summary(sapply(corpus, length))
# Create list of words in documents (will be used for frequency features)
wordList <- stylo::make.frequency.list(corpus)
# Count word occurrence in documents
frequencyTable <- stylo::make.table.of.frequencies(corpus, features = wordList)
# Remove words which only occur in certain fraction of documents
frequencyTable <- stylo::perform.culling(frequencyTable, culling.level = 10)

### Analysis
classLabels <- factor(sapply(strsplit(rownames(frequencyTable), split = "_"),
                             function(x) x[1]))
table(classLabels)

## Clustering
distObject <- stylo::dist.cosine(frequencyTable)
clusteringResult <- hclust(distObject, method = "ward.D2")
clusterAssignments <- cutree(clusteringResult, k = 3)
table(clusterAssignments, classLabels)

## Classification
jsmIdx <- which(classLabels == "jsm")
htmIdx <- which(classLabels == "htm")
comIdx <- which(classLabels == "htm+jsm")
trainFraction <- 0.8
set.seed(25)
trainJsmIdx <- sample(jsmIdx, size = round(trainFraction * length(jsmIdx)))
trainHtmIdx <- sample(htmIdx, size = round(trainFraction * length(htmIdx)))
trainComIdx <- sample(comIdx, size = round(trainFraction * length(comIdx)))
trainIdx <- sample(c(trainJsmIdx, trainHtmIdx, trainComIdx))
# Baseline
baselinePrediction <- rep(names(which.max(table(classLabels[trainIdx]))),
                          times = length(classLabels) - length(trainIdx))
cat("Baseline accuracy:", sum(baselinePrediction == classLabels[-trainIdx]) /
      length(baselinePrediction), "\n")
# xgboost - needs class labels in [0, num_class)
xgbTrainData <- xgboost::xgb.DMatrix(data = frequencyTable[trainIdx, ],
    label = as.integer(classLabels)[trainIdx] - 1)
xgbModel <- xgboost::xgb.train(data = xgbTrainData, nrounds = 50,
    params = list(objective = "multi:softmax", num_class = 3, nthread = 4))
trainPrediction <- predict(xgbModel, newdata = frequencyTable[trainIdx, ])
cat("Train accuracy:", sum(levels(classLabels)[trainPrediction + 1] ==
    classLabels[trainIdx]) / length(trainPrediction), "\n")
testPrediction <- predict(xgbModel, newdata = frequencyTable[-trainIdx, ])
cat("Test accuracy:", sum(levels(classLabels)[testPrediction + 1] ==
    classLabels[-trainIdx]) / length(testPrediction), "\n")
