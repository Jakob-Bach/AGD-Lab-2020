library(data.table)

inputPath <- "data/" # adapt this

# Get names of split files
truthFiles <- list.files("data/", pattern = "split_test_labels_.*\\.csv", full.names = TRUE)
if (length(truthFiles) == 0) {
  stop("The ground truth files seem to have disappeared.")
}
if (length(list.files(inputPath, pattern = "prediction_[0-9]+\\.csv$")) != length(truthFiles)) {
  stop("Number of prediction and ground truth files differ.")
}

score <- 0 # will be averaged over splits
for (truthFileName in truthFiles) {
  seedString <- regmatches(truthFileName, regexpr("[0-9]+\\.csv$", truthFileName))
  predictionFileName <- list.files(inputPath, full.names = TRUE,
      pattern = paste0("prediction_", seedString))
  if (length(predictionFileName) != 1) {
    stop(paste0("Zero or multiple matching prediction files found for \"", seedString, "\"."))
  }
  groundTruth <- fread(truthFileName)
  prediction <- fread(predictionFileName, quote = FALSE, sep = ",")
  if (nrow(prediction) != nrow(groundTruth)) {
    stop("Number of observations wrong.")
  }
  if (ncol(prediction) != ncol(groundTruth)) {
    stop("Number of columns wrong.")
  }
  if (any(colnames(prediction) != colnames(groundTruth))) {
    stop("Column name wrong (quoted or wrong string).")
  }
  combinedTable <- merge(prediction, groundTruth, by = "id")
  score <- score + sum(combinedTable$status_group.x == combinedTable$status_group.y) / nrow(groundTruth)
}
print(round(score / length(truthFiles), digits = 3))
