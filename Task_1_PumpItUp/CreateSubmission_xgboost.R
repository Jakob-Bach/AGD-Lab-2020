# xgboost-based submission with a minimum amount of necessary pre-processing
library(data.table)

source("UtilityFunctions.R")

inputPath <- "data/"
outputPath <- "data/"

for (testValueFile in list.files(inputPath, pattern = "split_test_values_[0-9]+\\.csv", full.names = TRUE)) {
  ### Read in -----
  trainValues <- fread(gsub("test", "train", testValueFile), stringsAsFactors = TRUE)
  trainLabels <- fread(gsub("values", "labels", gsub("test", "train", testValueFile)), stringsAsFactors = TRUE)
  testValues <- fread(testValueFile, stringsAsFactors = TRUE)
  
  ### Pre-process -----
  # Exclude columns (one value, too many categories, id)
  uniqueColumns <- names(which(sapply(trainValues, function(x) uniqueN(x) == 1)))
  highCategoryColumns <- names(which(sapply(trainValues, function(x) {
    return(is.factor(x) && length(levels(x)) > 20)
  })))
  features <- setdiff(colnames(trainValues), c("id", uniqueColumns, highCategoryColumns))
  testIds <- testValues$id
  trainValues <- trainValues[, mget(features)]
  testValues <- testValues[, mget(features)]
  # Harmonize factor levels (introduces additional NAs, as new levels in test data)
  categoricalFeatures <- names(which(sapply(trainValues, is.factor)))
  testValues[, (categoricalFeatures) := lapply(categoricalFeatures, function(x)
    factor(get(x), levels = trainValues[, levels(get(x))]))]
  # Handle NAs
  naReplacements <- determineNAReplacements(trainValues)
  trainValues <- applyNAReplacements(trainValues, naReplacements)
  testValues <- applyNAReplacements(testValues, naReplacements)
  
  ### Train model -----
  xgbTrainPredictors <- Matrix::sparse.model.matrix(~ ., data = trainValues)[, -1]
  # xgboost needs class labels in [0, num_class): (will be re-transformed later)
  xgbTrainData <- xgboost::xgb.DMatrix(data = xgbTrainPredictors, label = as.integer(trainLabels$status_group) - 1)
  xgbTestPredictors <- Matrix::sparse.model.matrix(~ ., data = testValues)[, -1]
  xgbModel <- xgboost::xgb.train(data = xgbTrainData, nrounds = 50,
      params = list(objective = "multi:softmax", num_class = 3, nthread = 4))
  
  ### Predict -----
  trainPrediction <- predict(xgbModel, newdata = xgbTrainPredictors)
  cat("Train accuracy:", sum(levels(trainLabels$status_group)[trainPrediction + 1] ==
                               trainLabels$status_group) / length(trainPrediction), "\n")
  testPrediction <- predict(xgbModel, newdata = xgbTestPredictors)
  solution = data.table(id = testIds, status_group = levels(trainLabels$status_group)[testPrediction + 1])
  
  ### Write solution -----
  #seedString <- regmatches(testValueFile, regexpr("[0-9]+.csv$", testValueFile))
  fwrite(x = solution, file = paste0(outputPath, "prediction_", seedString),
         quote = FALSE, eol = "\n")
}
