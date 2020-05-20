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


# Mini functions to test if IAAO standards are met 
#' @describeIn cod Returns TRUE when input COD meets IAAO standards
#'   (between 5 and 15).
#' @param x Numeric vector of sales ratio statistic(s) to check
#'   against IAAO standards.
cod_met <- function(x) x >= 5.00 & x <= 15

#' @describeIn prd Returns TRUE when input PRD meets IAAO standards
#'   (between 0.98 and 1.03).
#' @inheritParams cod_met
prd_met <- function(x) x >= 0.98 & x <= 1.03

#' @describeIn prb Returns TRUE when input PRB meets IAAO standards
#'   (between -0.05 and 0.05).
#' @inheritParams cod_met
prb_met <- function(x) x >= -0.05 & x <= 0.05