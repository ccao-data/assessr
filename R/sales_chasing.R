# nolint start
#' Detect sales chasing in a vector of sales ratios
#'
#' @description Sales chasing is when a property is selectively reappraised to
#'   shift its assessed value toward its actual sale price. Sales chasing is
#'   difficult to detect. This function is NOT a statistical test and does
#'   not provide the probability of the given result. Rather, it combines two
#'   novel methods to roughly estimate if sales chasing has occurred.
#'
#'   The first method (dist) uses the technique outlined in the
#'   \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
#'   Appendix E, Section 4. It compares the percentage of real data within +-2%
#'   of the mean ratio to the percentage of data within the same bounds given a
#'   constructed normal distribution with the same mean and standard deviation.
#'   The intuition here is that ratios that are sales chased may be more
#'   "bunched up" in the center of the distribution.
#'
#'   The second method (cdf) detects discontinuities in the cumulative
#'   distribution function (CDF) of the input vector. Ratios that are not sales
#'   chased should have a fairly smooth CDF. Discontinuous jumps in the CDF,
#'   particularly around 1, may indicate sales chasing. This can usually be seen
#'   visually as a "flat spot" on the CDF.
#'
#' @param ratio A numeric vector of ratios centered around 1, where the
#'   numerator of the ratio is the estimated fair market value and the
#'   denominator is the actual sale price.
#' @param method Default "both". String indicating sales chasing detection
#'   method. Options are \code{cdf}, \code{dist}, or \code{both}.
#' @param na.rm Default FALSE. A boolean value indicating whether or not to
#'   remove NA values. If missing values are present but not removed the
#'   function will output NA for those values.
#' @param ... Named arguments passed on to methods.
#'
#' @return A logical value indicating whether or not the input ratios may
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
#' detect_chasing(normal_ratios)
#'
#' plot(stats::ecdf(chased_ratios))
#' detect_chasing(chased_ratios)
#' @export
detect_chasing <- function(ratio, method = "both", na.rm = FALSE, ...) {
  # nolint end

  # Check that inputs are well-formed numeric vector
  stopifnot(exprs = {
    method %in% c("cdf", "dist", "both")
    is.vector(ratio)
    is.numeric(ratio)
    !is.nan(ratio)
    length(ratio) > 2
    all(is.finite(ratio) | is.na(ratio)) # All values are finite OR are NA
  })

  # Warn about small sample sizes
  if (length(ratio) < 30) {
    warning(paste(
      "Sales chasing detection can be misleading when applied to small",
      "samples (N < 30). Increase N or use a different statistical test."
    ))
  }

  # Can't calculate ideal distribution if ratio input contains NA, so output NA
  if (any(is.na(ratio)) && !na.rm) {
    return(NA)
  }

  out <- switch(method,
    "cdf" = detect_chasing_cdf(ratio, ...),
    "dist" = detect_chasing_dist(ratio, na.rm = na.rm, ...),
    "both" = detect_chasing_cdf(ratio, ...) &
      detect_chasing_dist(ratio, na.rm = na.rm, ...)
  )

  return(out)
}


#' @describeIn detect_chasing CDF gap method for detecting sales chasing.
#' @param bounds Ratio boundaries to use for detection. The CDF method will
#'   return TRUE if the CDF gap exceeding the threshold is found within these
#'   bounds. The distribution method will calculate the percentage of ratios
#'   within these bounds for the actual data and an ideal normal distribution.
#'   Expanding these bounds increases likelihood of detection.
#' @param cdf_gap Ratios that have bunched up around a particular value
#'   (typically 1) will appear as a flat spot on the CDF. The longer this flat
#'   spot, the worse the potential sales chasing. This variable indicates the
#'   length of that flat spot and can be thought of as the proportion of ratios
#'   that have the same value. For example, 0.03 means that 3% of ratios share
#'   the same value.
detect_chasing_cdf <- function(ratio, bounds = c(0.98, 1.02), cdf_gap = 0.03, ...) { # nolint

  # Check that inputs are well-formed numeric vector
  stopifnot(
    cdf_gap > 0 & cdf_gap < 1, is.numeric(cdf_gap),
    length(bounds) == 2, is.numeric(bounds)
  )

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
  out <- max(diffs) > cdf_gap & (diff_loc > bounds[1] & diff_loc < bounds[2])

  return(out)
}


#' @describeIn detect_chasing Distribution comparison method
#'   for detecting sales chasing.
detect_chasing_dist <- function(ratio, bounds = c(0.98, 1.02), na.rm = FALSE, ...) { # nolint

  # Check that inputs are well-formed numeric vector
  stopifnot(length(bounds) == 2, is.numeric(bounds))

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

  return(pct_actual > pct_ideal)
}
