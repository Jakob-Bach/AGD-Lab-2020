library(data.table)

# Determines potential replacement values for NAs in a dataset (data.frame).
# Uses the median for numeric values and the mode for all other values.
# Returns a list with one entry for each of the original columns.
determineNAReplacements <- function(dataset) {
  return(lapply(dataset, function(column) {
    if (is.numeric(column)) { # take the median
      result <- median(column,na.rm = TRUE)
      if (is.integer(column)) { # median might fall between values, we want true integer
        result <- as.integer(result)
      }
    } else {# take the mode
      # see https://stackoverflow.com/questions/2547402/is-there-a-built-in-function-for-finding-the-mode
      uniqueColumn <- unique(column[!is.na(column)])
      if (length(uniqueColumn) == 0) { # pure NA column
        result <- NA # we can't help in that case ...
      } else {
        tab <- tabulate(match(column, uniqueColumn))
        result <- uniqueColumn[which.max(tab)]
      }
    }
    return(result)
  }))
}

# Takes a data.frame and a named list of replacement values and imputes NAs in
# the dataset with the corresponding replacement values. Returns a modified
# copy of the dataset.
applyNAReplacements <- function(dataset, replacements) {
  if (is.data.table(dataset)) {
    # prevent in-place-modification (to be consistent with data.frames, although
    # in-place modification would be more efficient)
    dataset <- copy(dataset)
  }
  for (colName in names(replacements)) {
    if (!(colName %in% colnames(dataset))) {
      warning(paste0("Column \"", colName, "\" does not exist in data and can ",
                     "therefore not be imputed."))
    }
    dataset[is.na(dataset[[colName]]), colName] <- replacements[[colName]]
  }
  return(dataset)
}
