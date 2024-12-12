#' Calculate bootstrapped confidence intervals
#'
#' @description Calculate the non-parametric bootstrap confidence interval
#'   for a given numeric input and a chosen function.
#'
#' @param FUN Function to bootstrap. Must return a single value.
#' @param estimate A numeric vector of estimated values. Must be the same
#'   length as \code{sale_price}.
#' @param sale_price A numeric vector of sale prices. Must be the same
#'   length as \code{estimate}.
#' @param nboot Default 1000. Number of iterations to use to estimate
#'   the output statistic confidence interval.
#' @param alpha Default 0.05. Numeric value indicating the confidence
#'   interval to return. 0.05 will return the 95\% confidence interval.
#' @param na.rm Default FALSE. A boolean value indicating whether or not to
#'   remove NA values. If missing values are present but not removed the
#'   function will output NA.
#'
#' @return A two-long numeric vector containing the bootstrapped confidence
#'   interval of the input vector(s).
#'
#' @examples
#'
#' # Calculate COD confidence interval
#' boot_ci(cod, ratios_sample$estimate, ratios_sample$sale_price, nboot = 100)
#'
#' # Calculate PRD confidence interval
#' boot_ci(
#'   prd,
#'   nboot = 100,
#'   estimate = ratios_sample$estimate,
#'   sale_price = ratios_sample$sale_price,
#'   na.rm = FALSE
#' )
#' @export
boot_ci <- function(
    FUN,
    estimate,
    sale_price,
    nboot = 1000,
    alpha = 0.05,
    na.rm = FALSE) {
  # Input checking and error handling
  check_inputs(estimate, sale_price)

  # Check that the input function returns a numeric vector
  est <- FUN(estimate, sale_price)
  stopifnot(
    length(est) == 1,
    is.numeric(est),
    is.logical(na.rm),
    nboot > 0
  )

  # Create an index of missing values, where TRUE when missing.
  # If na.rm is FALSE and index contains TRUE, return NA
  missing_idx <- index_na(estimate, sale_price)
  if (any(missing_idx) && !na.rm) {
    return(NA_real_)
  }

  # Get the length of the inputs by summing opposite of the missing index
  # NA values in the index are TRUE, so by negating the index and summing, we
  # can get the total number of non-missing values
  n <- sum(!missing_idx)
  ests <- numeric(nboot)

  # Bootstrapping
  for (i in seq_len(nboot)) {
    # For each iteration, sample indices between 1 and the number of
    # non-missing values
    idx <- sample(1:n, replace = TRUE)

    # For each of the input vectors to FUN, subset by first removing any
    # index positions that have a missing value, then take a random sample of
    # each vector using the sample index
    sampled <- lapply(
      list(estimate, sale_price),
      function(x) x[!missing_idx][idx]
    )

    # For each bootstrap sample, apply the function and output an estimate for
    # that sample
    ests[i] <- do.call(FUN, sampled)
  }

  ci <- c(
    stats::quantile(ests, alpha / 2),
    stats::quantile(ests, 1 - alpha / 2)
  )

  return(ci)
}


#' @inheritParams boot_ci
#' @describeIn cod Returns upper and lower CI as a named vector.
#' @order 2
#'
#' @examples
#'
#' # Calculate COD confidence interval
#' cod_ci(ratios_sample$estimate, ratios_sample$sale_price)
#' @export
cod_ci <- function(
    estimate,
    sale_price,
    nboot = 1000,
    alpha = 0.05,
    na.rm = FALSE) {
  cod_ci <- boot_ci(
    cod,
    estimate = estimate,
    sale_price = sale_price,
    nboot = nboot,
    alpha = alpha,
    na.rm = na.rm
  )

  return(cod_ci)
}


#' @inheritParams cod_ci
#' @describeIn prd Returns upper and lower CI as a named vector.
#' @order 2
#'
#' @examples
#'
#' # Calculate PRD confidence interval
#' prd_ci(ratios_sample$estimate, ratios_sample$sale_price)
#' @export
prd_ci <- function(
    estimate,
    sale_price,
    nboot = 1000,
    alpha = 0.05,
    na.rm = FALSE) {
  prd_ci <- boot_ci(
    prd,
    estimate = estimate,
    sale_price = sale_price,
    nboot = nboot,
    alpha = alpha,
    na.rm = na.rm
  )

  return(prd_ci)
}


#' @inheritParams prd_ci
#' @describeIn prb Returns upper and lower CI as a named vector.
#' @order 2
#'
#' @examples
#'
#' # Calculate PRD confidence interval
#' prb_ci(ratios_sample$estimate, ratios_sample$sale_price)
#' @export
prb_ci <- function(estimate, sale_price, alpha = 0.05, na.rm = FALSE) {
  # Input checking and error handling
  check_inputs(estimate, sale_price)

  # Remove NAs from input vectors. Otherwise, return NA if the input vectors
  # contain any NA values
  idx <- index_na(estimate, sale_price)
  if (na.rm) {
    estimate <- estimate[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  # Calculate PRB model
  prb_model <- calc_prb(estimate, sale_price)

  # Extract PRB CI from model
  prb_ci <- stats::confint(prb_model, level = (1 - alpha))[2, ]

  return(prb_ci)
}
