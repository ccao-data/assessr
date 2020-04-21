#' Calculate Coefficient of Dispersion (COD)
#'
#' Measure the COD of a vector of assessment ratios. Used by the CCAO to
#' measure the uniformity of assessment models.
#'
#' @param ratios A vector of ratios centered around 1, where the numerator of
#'   the ratio is the estimated fair cash value and the denominator
#'   is the sale price. NOTE: These values are typically lagged or leading
#'   to prevent sales chasing.
#' @param trim A lower and upper quantile for trimming input vectors. These
#'   values are set by CCAO Data Science Department SOPs. Do not alter
#'   them without permission.
#' @param bootstrap_n The number of iterations to use to estimate the output
#'   statistic, standard error, and 95\% confidence interval.
#'   Setting to 0 or FALSE will not use bootstrapping.
#' @param suppress Default FALSE. If TRUE, hide warning about not meeting the
#'   minimum number of observations to calculate a statistic accurately. The
#'   minimum value of observation for accurate statistics is 30, per CCAO SOPs.
#' @param na_rm Default FALSE. If TRUE, will remove NAs from the vector before
#'   proceeding.
#'
#' @return A named list containing the statistic, standard error,
#'   95\% confidence interval, and the number of observations used
#'   in the calculation.
#'
#' @examples
#' library(assessr)
#'
#' # Load the included dataset
#' data("ratios_sample")
#'
#' cod_func(ratios_sample$ratios, trim = c(0.05, 0.95), bootstrap_n = 100)
#' @family assmnt_functions
#' @export
cod_func <- function(ratios,
                     trim = c(0.05, 0.95),
                     bootstrap_n = 100,
                     suppress = FALSE,
                     na_rm = FALSE) {

  # Input checking and error handling
  stopifnot(
    # Check for ratios input
    is.vector(ratios), # Input is vector
    is.numeric(ratios), # Input is numeric
    !(anyNA(ratios) & !na_rm), # No NAs when na_rm is FALSE
    !is.nan(ratios) # No NaNs in inputs
  )

  # Subset ratios by removing NAs (assumes na_rm = TRUE, otherwise will fail)
  ratios <- subset(ratios, !is.na(ratios))

  # Create the 5th and 95th percentile trimming boundaries. All values outside
  # of these will be dropped, per CCAO SOPs
  trim_boundaries <- stats::quantile(ratios, probs = trim)

  # This minimum observation limit is defined by CCAO Data Science SOPs
  # Do not alter without updating SOPs
  if (length(ratios) >= 30) {

    # Get only the ratios between trimming bounardies
    ratios <- subset(
      ratios, ratios >= trim_boundaries[1] &
        ratios <= trim_boundaries[2]
    )

    # Run bootstrap interations to calulate stat, se and 95% CI
    if (bootstrap_n == 0 | !bootstrap_n) {
      n <- length(ratios)
      generated_cods <- 100 * sum(abs(ratios - stats::median(ratios))) /
        (n * stats::median(ratios))
    } else {
      n <- length(ratios)
      generated_cods <- numeric(bootstrap_n)
      for (i in seq_len(bootstrap_n)) {
        s <- sample(ratios, n, replace = TRUE)
        generated_cods[i] <- 100 * sum(abs(s - stats::median(s))) /
          (n * stats::median(s))
      }
    }

    # Create a named output vector containing COD, SE, 95% CI, and N
    cod_output <- list(
      round(mean(generated_cods, na.rm = TRUE), 4),
      round(stats::sd(generated_cods, na.rm = TRUE) / sqrt(length(ratios)), 4),
      paste0(
        "(",
        round(
          mean(generated_cods, na.rm = TRUE) - 1.96 *
            stats::sd(generated_cods, na.rm = TRUE), 4
        ),
        ", ",
        round(
          mean(generated_cods, na.rm = TRUE) + 1.96 *
            stats::sd(generated_cods, na.rm = TRUE), 4
        ),
        ")"
      ),
      n
    )
  } else {

    # Output NA values if suppress = TRUE
    cod_output <- list(NA, NA, NA, NA)

    if (!suppress) {
      stop("Less than 30 observations, too few for reliable sale ratio stats")
    }
  }

  names(cod_output) <- c("COD", "COD_SE", "COD_95CI", "COD_N")
  return(cod_output)
}


#' Calculate Price-related Differential (PRD)
#'
#' Measure the PRD of a vector of assessment ratios and a corresponding vector
#' of sales. Used by the CCAO to measure the vertical equity of assessment
#' models.
#'
#' @inherit cod_func
#' @param sales A vector of sales the same length as \code{ratios}.
#'
#' @examples
#' library(assessr)
#'
#' # Load the included dataset
#' data("ratios_sample")
#'
#' prd_func(
#'   ratios_sample$ratios,
#'   ratios_sample$sales,
#'   trim = c(0.05, 0.95),
#'   bootstrap_n = 100
#' )
#' @family assmnt_functions
#' @export
prd_func <- function(ratios,
                     sales,
                     trim = c(0.05, 0.95),
                     bootstrap_n = 100,
                     suppress = FALSE,
                     na_rm = FALSE) {

  # Input checking and error handling
  stopifnot(
    # Check for ratios input
    is.vector(ratios), # Input is vector
    is.numeric(ratios), # Input is numeric
    !(anyNA(ratios) & !na_rm), # No NAs when na_rm is FALSE
    !is.nan(ratios), # No NaNs in inputs

    # Checking for sales input
    is.vector(sales), # Input is vector
    is.numeric(sales), # Input is numeric
    !(anyNA(sales) & !na_rm), # No NAs when na_rm is FALSE
    !is.nan(sales), # No NaNs in inputs

    # All input checks
    length(ratios) == length(sales) # Input vectors equal length
  )

  # Subset inputs by removing NAs (assumes na_rm = TRUE, otherwise will fail)
  x <- stats::na.omit(data.frame(cbind(ratios, sales)))

  # Create the 5th and 95th percentile trimming boundaries. All values outside
  # of these will be dropped, per CCAO SOPs
  trim_boundaries <- stats::quantile(x$ratios, probs = trim)

  # This minimum observation limit is defined by CCAO Data Science SOPs
  # Do not alter without updating SOPs
  if (nrow(x) >= 30) {

    # Get only the ratios between trimming bounardies
    x <- subset(
      x, x$ratios >= trim_boundaries[1] &
        x$ratios <= trim_boundaries[2]
    )

    # Run bootstrap interations to calulate stat, se and 95% CI
    if (bootstrap_n == 0 | !bootstrap_n) {
      generated_prds <- mean(x[, 1], na.rm = TRUE) /
        stats::weighted.mean(x[, 1], x[, 2], na.rm = TRUE)
    } else {
      generated_prds <- numeric(bootstrap_n)
      for (i in seq_len(bootstrap_n)) {
        # Sample dataframe of ratios and sales with replacement
        df <- x[sample.int(nrow(x), replace = TRUE), ]
        generated_prds[i] <- mean(df[, 1], na.rm = TRUE) /
          stats::weighted.mean(df[, 1], df[, 2], na.rm = TRUE)
      }
    }

    prd_output <- list(
      round(mean(generated_prds, na.rm = TRUE), 4),
      round(stats::sd(generated_prds, na.rm = TRUE) / sqrt(nrow(x)), 4),
      paste0(
        "(",
        round(mean(generated_prds, na.rm = TRUE) - 1.96 *
          stats::sd(generated_prds, na.rm = TRUE), 4),
        ", ",
        round(mean(generated_prds, na.rm = TRUE) + 1.96 *
          stats::sd(generated_prds, na.rm = TRUE), 4),
        ")"
      ),
      nrow(x)
    )
  } else {

    # Output NA values if suppress = TRUE
    prd_output <- list(NA, NA, NA, NA)

    if (!suppress) {
      stop("Less than 30 observations, too few for sale reliable ratio stats")
    }
  }

  names(prd_output) <- c("PRD", "PRD_SE", "PRD_95CI", "PRD_N")
  return(prd_output)
}


#' Calculate Price-related Bias (PRB)
#'
#' Measure the PRB of a vector of assessment ratios and corresponding vectors
#' of assessment ratios and sales. Used by the CCAO to measure the
#' vertical equity of assessment models.
#'
#' PRB is calculated using a regression method and has a closed-form solution
#' for calculating standard errors. As a result, there is no need for
#' bootstrapping.
#'
#' @inherit prd_func
#' @param assessed_values A vector AVs the same length as \code{ratios}.
#'
#' @examples
#' library(assessr)
#'
#' # Load the included dataset
#' data("ratios_sample")
#'
#' prb_func(
#'   ratios_sample$ratios,
#'   ratios_sample$sales,
#'   ratios_sample$assessed_values,
#'   trim = c(0.05, 0.95)
#' )
#' @family assmnt_functions
#' @export
prb_func <- function(ratios,
                     sales,
                     assessed_values,
                     trim = c(0.05, 0.95),
                     suppress = FALSE,
                     na_rm = FALSE) {

  # Input checking and error handling
  stopifnot(
    # Check for ratios input
    is.vector(ratios), # Input is vector
    is.numeric(ratios), # Input is numeric
    !(anyNA(ratios) & !na_rm), # No NAs when na_rm is FALSE
    !is.nan(ratios), # No NaNs in inputs

    # Checking for sales input
    is.vector(sales), # Input is vector
    is.numeric(sales), # Input is numeric
    !(anyNA(sales) & !na_rm), # No NAs when na_rm is FALSE
    !is.nan(sales), # No NaNs in inputs

    # Checking for assessed_values input
    is.vector(assessed_values), # Input is vector
    is.numeric(assessed_values), # Input is numeric
    !(anyNA(assessed_values) & !na_rm), # No NAs when na_rm is FALSE
    !is.nan(assessed_values), # No NaNs in inputs

    # All input checks
    length(ratios) == length(sales), # Input vectors equal length
    length(ratios) == length(assessed_values) # Input vectors equal length
  )

  # Subset inputs by removing NAs (assumes na_rm = TRUE, otherwise will fail)
  x <- stats::na.omit(data.frame(cbind(ratios, assessed_values, sales)))

  # Create the 5th and 95th percentile trimming boundaries. All values outside
  # of these will be dropped, per CCAO SOPs
  trim_boundaries <- stats::quantile(x$ratios, probs = trim)

  # This minimum observation limit is defined by CCAO Data Science SOPs
  # Do not alter without updating SOPs
  if (nrow(x) >= 30) {

    # Get only the ratios between trimming bounardies
    x <- subset(
      x, x$ratios >= trim_boundaries[1] &
        x$ratios <= trim_boundaries[2]
    )

    x$log2 <- log(2)

    # Generate PRB from regression model
    generated_prbs <- stats::lm(
      ((ratios - stats::median(ratios)) / stats::median(ratios)) ~
      I(log(0.5 * (sales + assessed_values / stats::median(sales))) / log2),
      data = x
    )

    # Output the coefficients of formula to a list
    prb_output <- list(
      round(stats::summary.lm(generated_prbs)$coefficients[2, 1], 4),
      round(stats::summary.lm(generated_prbs)$coefficients[2, 2], 4),
      paste0(
        "(",
        round(stats::confint(generated_prbs)[2, 1], 4),
        ", ",
        round(stats::confint(generated_prbs)[2, 2], 4),
        ")"
      ),
      stats::nobs(generated_prbs)
    )
  } else {

    # Output NA values if suppress = TRUE
    prb_output <- list(NA, NA, NA, NA)

    if (!suppress) {
      stop("Less than 30 observations, too few for sale reliable ratio stats")
    }
  }

  names(prb_output) <- c("PRB", "PRB_SE", "PRB_95CI", "PRB_N")
  return(prb_output)
}
