library(data.table)

seedValues <- 25
trainFraction <- 0.8

# Read in as character to make sure that no re-formatting happens
dataValues <- fread("data/train_values.csv", colClasses = "character", strip.white = FALSE)
dataLabels <- fread("data/train_labels.csv", colClasses = "character", strip.white = FALSE)
stopifnot(all(dataValues$id == dataLabels$id)) # make sure rows are aligned

for (seedValue in seedValues) {
  set.seed(seedValue)
  classLabels <- factor(dataLabels$status_group)
  classIdx <- sapply(levels(classLabels), function(x) which(classLabels == x))
  trainIdx <- sapply(classIdx, function(x) sample(x, size = round(0.8 * length(x)), replace = FALSE))
  trainIdx <- sort(unlist(trainIdx))
  trainValues <- dataValues[trainIdx, ]
  trainLabels <- dataLabels[trainIdx, ]
  testValues <- dataValues[-trainIdx, ]
  testLabels <- dataLabels[-trainIdx, ]
  fwrite(trainValues, file = paste0("data/split_train_values_", seedValue, ".csv"),
         quote = FALSE, eol = "\n")
  fwrite(trainLabels, file = paste0("data/split_train_labels_", seedValue, ".csv"),
         quote = FALSE, eol = "\n")
  fwrite(testValues, file = paste0("data/split_test_values_", seedValue, ".csv"),
         quote = FALSE, eol = "\n")
  fwrite(testLabels, file = paste0("data/split_test_labels_", seedValue, ".csv"),
         quote = FALSE, eol = "\n")
}
