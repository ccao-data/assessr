# nolint start
#' Detect sales chasing in a vector of sales ratios
#'
#' @description Sales chasing is when a property is selectively reappraised to
#'   shift its assessed value toward its recent sale price. Sales chasing is
#'   difficult to detect. This function is NOT a statistical test and does
#'   not provide the probability of the given result. Rather, it combines two
#'   heuristic methods to roughly estimate if sales chasing has occurred.
#'
#'   The first method (cdf) detects discontinuities in the cumulative
#'   distribution function (CDF) of the input vector. Ratios that are not sales
#'   chased should have a fairly smooth CDF. Discontinuous jumps in the CDF,
#'   particularly around 1, may indicate sales chasing. This can usually be seen
#'   visually as a "flat spot" on the CDF.
#'
#'   The second method (dist) uses the technique outlined in the
#'   \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
#'   Appendix E, Section 4. It compares the percentage of real data within +-2%
#'   of the mean ratio to the percentage of data within the same bounds given a
#'   constructed normal distribution with the same mean and standard deviation.
#'   The intuition here is that ratios that are sales chased may be more
#'   "bunched up" in the center of the distribution.
#'
#' @param x A numeric vector. Must be longer than 2 and cannot contain
#'   \code{inf} or \code{NA} values.
#' @param method Default \code{both}. String indicating sales chasing detection
#'   method. Options are \code{cdf}, \code{dist}, or \code{both}.
#' @param na.rm Default FALSE. A boolean value indicating whether or not to
#'   remove NA values. If missing values are present but not removed the
#'   function will output NA for those values.
#' @param bounds Default \code{(0.98, 1.02)}. Lower and upper bounds of the
#'   range of ratios to consider when detecting sales chasing. Setting this to
#'   a narrow band at the center of the ratio distribution prevents detecting
#'   false positives at the tails.
#' @param gap Default \code{0.05}. Float tuning factor. For the CDF method, it
#'   sets the maximum percentage difference between two adjacent ratios. For the
#'   distribution method, it sets the maximum percentage point difference
#'   between the percentage of the data between the \code{bounds} in the real
#'   distribution compared to the ideal distribution.
#'
#' @return A logical value indicating whether or not the input values may
#'   have been sales chased.
#'
#' @examples
#'
#' # Generate fake data with normal vs chased ratios
#' normal_ratios <- c(rnorm(1000, 1, 0.15))
#' chased_ratios <- c(rnorm(900, 1, 0.15), rep(1, 100))
#'
#' # Plot to view discontinuity
#' plot(stats::ecdf(normal_ratios))
#' is_sales_chased(normal_ratios)
#'
#' plot(stats::ecdf(chased_ratios))
#' is_sales_chased(chased_ratios)
#' @export
is_sales_chased <- function(x, method = "both", bounds = c(0.98, 1.02), gap = 0.03, na.rm = FALSE) {
  # nolint end

  # Check that inputs are well-formed numeric vector
  stopifnot(exprs = {
    method %in% c("cdf", "dist", "both")
    is.vector(x)
    is.numeric(x)
    !is.nan(x)
    length(x) > 2
    all(is.finite(x) | is.na(x)) # All values are finite OR are NA
    is.numeric(gap)
    gap > 0
    gap < 1
    is.vector(bounds)
    is.numeric(bounds)
    bounds[2] > bounds[1]
  })

  # Warn about small sample sizes
  if (length(x) < 30) {
    warning(paste(
      "Sales chasing detection can be misleading when applied to small",
      "samples (N < 30). Increase N or use a different statistical test."
    ))
  }

  # Can't calculate ideal distribution if ratio input contains NA, so output NA
  if (any(is.na(x)) && !na.rm) {
    return(NA)
  }

  out <- switch(method,
    "cdf" = cdf_sales_chased(x, bounds, gap),
    "dist" = dist_sales_chased(x, bounds, gap, na.rm = na.rm),
    "both" = cdf_sales_chased(x, bounds, gap) &
      dist_sales_chased(x, bounds, gap, na.rm = na.rm)
  )

  return(out)
}


#' @describeIn is_sales_chased CDF gap method for detecting sales chasing.
cdf_sales_chased <- function(ratio, bounds = c(0.98, 1.02), gap = 0.03) {
  # Sort the ratios AND REMOVE NAs
  sorted_ratio <- sort(ratio)

  # Calculate the CDF of the sorted ratios and extract percentile ranking
  cdf <- stats::ecdf(sorted_ratio)(sorted_ratio)

  # Calculate the difference between each value and the next value, the largest
  # difference will be the CDF gap
  diffs <- diff(cdf)

  # Check if the largest different is greater than the threshold and make sure
  # it's within the specified boundaries
  diff_loc <- sorted_ratio[which.max(diffs)]
  out <- max(diffs) > gap & (diff_loc > bounds[1] & diff_loc < bounds[2])

  return(out)
}


#' @describeIn is_sales_chased Distribution comparison method
#'   for detecting sales chasing.
dist_sales_chased <- function(
    ratio,
    bounds = c(0.98, 1.02),
    gap = 0.03,
    na.rm = FALSE) {
  # Return the percentage of x within the specified range
  pct_in_range <- function(x, min, max) mean(x >= min & x <= max, na.rm = na.rm)

  # Calculate the ideal normal distribution using observed values from input
  ideal_dist <- stats::rnorm(
    n = 10000,
    mean(ratio, na.rm = na.rm),
    stats::sd(ratio, na.rm = na.rm)
  )

  # Determine what percentage of the data would be within the specified bounds
  # in the ideal distribution
  pct_ideal <- pct_in_range(ideal_dist, bounds[1], bounds[2])

  # Determine what percentage of the data is actually within the bounds
  pct_actual <- pct_in_range(ratio, bounds[1], bounds[2])

  return(abs(pct_actual - pct_ideal) > gap)
}
