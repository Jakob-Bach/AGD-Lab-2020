# xgboost-based submission with a minimum amount of necessary pre-processing
library(data.table)

### Read in -----
trainValues <- fread("data/train_values.csv", stringsAsFactors = TRUE)
trainLabels <- fread("data/train_labels.csv", stringsAsFactors = TRUE)
testValues <- fread("data/test_values.csv", stringsAsFactors = TRUE)

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
# Handle NAs (appear in two logical cols, which both have more TRUE than FALSE in train)
trainValues[is.na(trainValues)] <- TRUE
testValues[is.na(testValues)] <- TRUE
# Harmonize factor levels (some levels do not appear in test data)
categoricalFeatures <- names(which(sapply(trainValues, is.factor)))
testValues[, (categoricalFeatures) := lapply(categoricalFeatures, function(x)
  factor(get(x), levels = trainValues[, levels(get(x))]))]
stopifnot(!anyNA(testValues)) # make sure that no new levels in test data

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
fwrite(x = solution, file = "data/submission_xgboost.csv")
