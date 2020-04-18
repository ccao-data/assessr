#' Calculate the COD of a given set of assessment ratios
#'
#' @param ratios A vector of ratios centered around 1, where the numerator of
#'   the ratio is the estimated fair cash value and the denominator
#'   is the sale price (sometimes lagged or leading).
#' @param trim A lower and upper bound for trimming assessment ratios. These
#'   values are set by CCAO Data Science Department SOPs. Do not alter
#'   them without permission.
#' @param bootstrap_n The number of iterations to use to estimate standard error
#'   and 95\% confidence interval. Setting to 0 or FALSE will not use bootstrap.
#' @param suppress Default FALSE. If TRUE, hide warning about not meeting the
#'   minimum number of ratios to calculate COD accurately dplyr (30 by default).
#' @param na_rm Default FALSE. If TRUE, will remove NAs from the vector before
#'   proceeding.
#'
#' @return A named list containing COD, standard error, 95\% confidence
#'   interval, and the number of ratios used in the calculation
#'
#' @examples
#' library(assessR)
#'
#' ratios <- runif(300, 0.93, 1.08)
#'
#' cod_func(ratios, trim = c(0.05, 0.95), bootstrap_n = 100)
#' @export
cod_func <- function(ratios,
                     trim = c(0.05, 0.95),
                     bootstrap_n = 100,
                     suppress = FALSE,
                     na_rm = FALSE) {

  # Throw an error if missing or malformed ratio values
  if (anyNA(ratios) && !na_rm) {
    stop(
      "The ratios vector contains missing values.
      Remove them manually or set na.rm = TRUE."
    )
  } else if (any(is.nan(ratios))) {
    stop("The ratios vector contains NaN values.")
  } else if (any(!is.numeric(ratios))) {
    stop("The ratios vector contains non-numeric values.")
  } else {
    # Remove missing values
    ratios <- subset(ratios, !is.na(ratios))
  }

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

    # Run bootstrap interations to determine se and 95% CI
    if (bootstrap_n == 0 | !bootstrap_n) {
      n <- length(ratios)
      generated_cods <- 100 * sum(abs(ratios - stats::median(ratios))) /
        (n * stats::median(ratios))
    } else {
      generated_cods <- NULL
      for (i in seq_len(bootstrap_n)) {
        n <- length(ratios)
        s <- sample(ratios, n, replace = TRUE)
        generated_cods[i] <- 100 * sum(abs(s - stats::median(s))) /
          (n * stats::median(s))
      }
    }

    # Create a named output vector containing COD, SE, 95% CI, and N
    cod_output <- list(
      round(mean(generated_cods, na.rm = TRUE), 4),
      round(stats::sd(generated_cods, na.rm = TRUE), 4),
      paste0(
        "(",
        round(
          mean(generated_cods, na.rm = TRUE) - 1.96 *
            stats::sd(generated_cods, na.rm = TRUE),
          4
        ),
        ", ",
        round(
          mean(generated_cods, na.rm = TRUE) + 1.96 *
            stats::sd(generated_cods, na.rm = TRUE),
          4
        ),
        ")"
      ), n
    )
  } else {

    # Output NA values if suppress = TRUE
    cod_output <- c(NA, NA, NA, NA)

    if (!suppress) {
      stop("Less than 30 observations, too few for reliable sale ratio stats")
    }
  }

  names(cod_output) <- c("COD", "COD_SE", "COD_95CI", "COD_N")
  return(cod_output)
}
