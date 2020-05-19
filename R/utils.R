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
