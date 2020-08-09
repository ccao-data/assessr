# Input checking and error handling
# Checks the listed conditions for all inputs
check_inputs <- function(...) {
  # Get lengths of all input vectors
  lens <- sapply(list(...), function(x) length(x))

  # Run the following checks for each input
  lapply(list(...), function(x) {
    stopifnot(exprs = {
      is.vector(x)
      is.numeric(x)
      !is.nan(x)
      length(x) > 1
      all(lens == lens[1]) # All input vectors are same length
      all(is.finite(x) | is.na(x)) # All values are finite OR are NA
      all(x != 0 | is.na(x)) # All values are not zero OR are NA
    })
  })
}


# Create an index of all missing values in the input vectors
index_na <- function(...) {

  # Create a list of lists containing missing vals in each input
  # Merge lists into single index where if one list has NA, idx value is TRUE
  idx <- as.logical(Reduce("+", lapply(list(...), is.na)))

  return(idx)
}


# De-mean lat and lon coords such that their rescaled values will be relative
# to one another (distance from a shared center point)
demean_coords <- function(x, y) {
  demeaned_coords <- c((x - mean(x)), y - mean(y))
  range(demeaned_coords)
}


# Rescale numeric vector to be between 0 and 1
# Taken from the scales library
rescale <- function(x, to = c(0, 1), from = range(x, na.rm = T, finite = T)) {
  (x - from[1]) / diff(from) * diff(to) + to[1]
}


# Function to rescale new data RELATIVE to old input data. This can be called
# directly but is called implicitly in predict()
rescale_data <- function(data, newdata) {

  # Create row incides for both the old and new data
  data_idx <- seq_len(nrow(data))
  newdata_idx <- seq_len(nrow(newdata)) + nrow(data)

  # Combine the datasets
  df <- rbind(as.data.frame(data), as.data.frame(newdata))

  # For each factor column, relevel according to levels from old data
  fct_cols <- which(unlist(lapply(df, is.factor)))
  rlvl <- function(x) factor(x, levels = levels(factor(x[data_idx])))
  df[fct_cols] <- lapply(df[fct_cols], rlvl)

  # For each numeric column, rescale according to min/max from old data
  num_cols <- which(unlist(lapply(df, is.numeric)))
  rscl <- function(x) rescale(x, from = range(x[data_idx], na.rm = T))
  df[num_cols] <- lapply(df[num_cols], rscl)

  # Return only the new data from the combined df
  return(df[newdata_idx, ])
}
