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
