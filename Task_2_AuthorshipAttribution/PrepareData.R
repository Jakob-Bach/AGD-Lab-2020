inputPath <- "C:/MyData/Corpus_raw/" # place it high in file hierarchy, or some files might not be copied (file names are very long)
outputPath <- "data/corpus/"

unlink(paste(outputPath, "*"), recursive = TRUE)
dir.create(outputPath, recursive = TRUE, showWarnings = FALSE)
inputFiles <- list.files(path = inputPath, recursive = TRUE)
for (inputFile in inputFiles) {
  outputFile <- basename(inputFile)
  if (grepl("^jsm_[0-9]+", outputFile)) { # shorten article names
    outputFile <- paste0(regmatches(outputFile, regexpr("^jsm_[0-9]+", outputFile)),
                         regmatches(outputFile, regexpr("_18[0-9][0-9]", outputFile)))
  }
  file.copy(from = paste0(inputPath, inputFile), to = paste0(outputPath, outputFile))
}
