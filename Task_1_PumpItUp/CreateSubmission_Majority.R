# Baseline submission which simply predicts the majority class from the training data
library(data.table)

trainLabels <- fread("data/train_labels.csv")
testValues <- fread("data/test_values.csv")
majorityClass <- trainLabels[, .N, by = status_group][N == max(N), status_group]
fwrite(x = data.table(id = testValues$id, status_group = majorityClass),
       file = "data/submission_majority.csv")
