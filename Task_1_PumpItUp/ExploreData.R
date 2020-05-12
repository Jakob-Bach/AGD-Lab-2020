library(data.table)

trainValues <- fread("data/train_values.csv", stringsAsFactors = TRUE)
trainLabels <- fread("data/train_labels.csv", stringsAsFactors = TRUE)
testValues <- fread("data/test_values.csv", stringsAsFactors = TRUE)

# General info
nrow(trainValues) / (nrow(trainValues) + nrow(testValues))
trainLabels[, .N, by = status_group][, .(status_group, N, Fraction = N / sum(N))]

# Column types
table(sapply(trainValues, class))
names(which(sapply(trainValues, is.logical)))
names(which(sapply(trainValues, is.integer)))
names(which(sapply(trainValues, is.double)))
categoricalCols <- names(which(sapply(trainValues, is.factor)))
categoricalCols
sort(sapply(categoricalCols, function(x) length(levels(trainValues[[x]]))))

# Categories in training and test
for (categoricalCol in categoricalCols) {
  cat(categoricalCol, ":", sep = "")
  trainLevels <- levels(trainValues[[categoricalCol]])
  testLevels <- levels(testValues[[categoricalCol]])
  if ((length(trainLevels) == length(testLevels)) && all(trainLevels == testLevels)) {
    cat("Same levels in train and test.")
  }
  if (length(setdiff(trainLevels, testLevels)) > 0) {
    cat("Additional levels in train. ")
  }
  if (length(setdiff(testLevels, trainLevels)) > 0) {
    cat("Additional levels in test. ")
  }
  cat("\n")
}

# NAs
sapply(trainValues, function(x) sum(is.na(x) | x == ""))
sapply(testValues, function(x) sum(is.na(x) | x == ""))
names(which(sapply(trainValues, function(x) anyNA(x) || any(x == ""))))
names(which(sapply(testValues, function(x) anyNA(x) || any(x == ""))))
