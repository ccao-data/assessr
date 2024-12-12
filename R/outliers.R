# nolint start
#' Detect outlier values in a vector using IQR/quantile method
#'
#' @description Detect outliers in a numeric vector using standard methods.
#'
#'   Certain assessment performance statistics are sensitive to extreme
#'   outliers. As such, it is often necessary to remove outliers before
#'   performing a sales ratio study.
#'
#'   The IAAO standard method is to remove outliers that are 3 * IQR. Warnings are thrown
#'   when sample size is extremely small or when the IQR is extremely narrow. See
#'   \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
#'   Appendix B. Outlier Trimming Guidelines for more information.
#'
#' @param x A numeric vector, typically sales ratios. Must be longer than 2 and
#'   cannot contain \code{Inf} or \code{NaN}.
#' @param method Default \code{iqr.} String indicating outlier detection method.
#'   Options are \code{iqr} or \code{quantile}.
#' @param probs Upper and lower percentiles denoting outlier boundaries for
#'   the \code{quantile} method.
#' @param mult Multiplier for IQR to determine outlier boundaries. Default 3.
#'
#' @return A logical vector this same length as \code{x} indicating whether or
#'   not each value of \code{x} is an outlier.
#'
#' @export
is_outlier <- function(x, method = "iqr", probs = c(0.05, 0.95), mult = 3) {
  # nolint end

  # Check that inputs are well-formed numeric vector
  stopifnot(exprs = {
    method %in% c("quantile", "iqr")
    is.vector(x)
    is.numeric(x)
    !is.nan(x)
    length(x) > 2
    all(is.finite(x) | is.na(x)) # All values are finite OR are NA
  })

  if (method == "quantile") {
    out <- quantile_outlier(x, probs = probs)
  } else {
    out <- iqr_outlier(x, mult = mult)
  }

  # Warn about removing data from small samples, as it can severely distort
  # ratio study outcomes
  if (any(out) && length(out) < 30) {
    warning(paste(
      "Values flagged as outliers despite small sample size (N < 30).",
      "Use caution when removing values from a small sample."
    ))
  }

  return(out)
}


#' @describeIn is_outlier Quantile method for identifying outliers.
#' @param probs Upper and lower percentiles denoting outlier boundaries.
quantile_outlier <- function(x, probs = c(0.05, 0.95)) {
  # Determine valid range of the data
  range <- stats::quantile(x, probs = probs, na.rm = TRUE)

  # Determine which input values are in range
  out <- x < range[1] | x > range[2]

  return(out)
}


#' @describeIn is_outlier IQR method for identifying outliers.
#' @param mult Multiplier for IQR to determine outlier boundaries.
iqr_outlier <- function(x, mult = 3) {
  # Check that inputs are well-formed numeric vector
  stopifnot(is.numeric(mult), sign(mult) == 1)

  # Calculate quartiles and mult*IQR
  quartiles <- stats::quantile(x, probs = c(0.25, 0.75), na.rm = TRUE)
  iqr_mult <- mult * stats::IQR(x, na.rm = TRUE)

  # Find values that are outliers
  out <- x < (quartiles[1] - iqr_mult) | x > (quartiles[2] + iqr_mult)

  # Warn if IQR trimmed values are within 95% CI. This indicates potentially
  # non-normal/narrow distribution of data
  if (any(out & !quantile_outlier(x), na.rm = TRUE)) {
    warning(paste(
      "Some values flagged as outliers despite being within 95% CI.",
      "Check for narrow or skewed distribution."
    ))
  }

  return(out)
}
