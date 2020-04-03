# Baseline submission which simply predicts the majority class from the training data
library(data.table)

inputPath <- "data/"
outputPath <- "data/"

for (testValueFile in list.files(inputPath, pattern = "split_test_values_[0-9]+\\.csv", full.names = TRUE)) {
  # Read in
  testValues <- fread(testValueFile)
  trainLabels <- fread(gsub("values", "labels", gsub("test", "train", testValueFile)))
  
  # Determine majority class
  majorityClass <- trainLabels[, .N, by = status_group][N == max(N), status_group]
  
  # Write output
  seedString <- regmatches(testValueFile, regexpr("[0-9]+.csv$", testValueFile))
  fwrite(x = data.table(id = testValues$id, status_group = majorityClass),
         file = paste0(outputPath, "prediction_", seedString), quote = FALSE, eol = "\n")
}
