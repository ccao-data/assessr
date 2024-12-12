##### COD #####

# nolint start
#' Calculate Coefficient of Dispersion (COD)
#'
#' @description COD is the average absolute percent deviation from the
#'   median ratio. It is a measure of horizontal equity in assessment.
#'   Horizontal equity means properties with a similar fair market value
#'   should be similarly assessed.
#'
#'   Lower COD indicates higher uniformity/horizontal equity in assessment.
#'   The IAAO sets uniformity standards that define generally accepted ranges
#'   for COD depending on property class. See
#'   \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
#'   Section 9.1, Table 1.3 for a full list of standard COD ranges.
#'
#'   NOTE: The IAAO recommends trimming outlier ratios before calculating COD,
#'   as it is extremely sensitive to large outliers. The typical method used is
#'   dropping values beyond 3 * IQR (inner-quartile range). See
#'   \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
#'   Appendix B.1.
#'
#' @param estimate A numeric vector of assessed values. Must be the same
#'   length as \code{sale_price}.
#' @param sale_price A numeric vector of sale prices. Must be the same length
#'   as \code{estimate}.
#' @param na.rm Default FALSE. A boolean value indicating whether or not to
#'   remove NA values. If missing values are present but not removed the
#'   function will output NA.
#'
#' @describeIn cod Returns a numeric vector containing the COD of \code{ratios}.
#' @order 1
#'
#' @examples
#' # Calculate COD
#' cod(ratios_sample$estimate, ratios_sample$sale_price)
#' @family formulas
#' @export
cod <- function(estimate, sale_price, na.rm = FALSE) {
  # nolint end

  check_inputs(estimate, sale_price)
  ratio <- estimate / sale_price

  if (na.rm) ratio <- stats::na.omit(ratio)

  # Calculate median ratio
  med_ratio <- stats::median(ratio)

  # Calculate COD
  cod <- (mean(abs(ratio - med_ratio)) / med_ratio) * 100

  return(cod)
}



##### PRD #####

# nolint start
#' Calculate Price-Related Differential (PRD)
#'
#' @description PRD is the mean ratio divided by the mean ratio weighted by sale
#'   price. It is a measure of vertical equity in assessment. Vertical equity
#'   means that properties at different levels of the income distribution
#'   should be similarly assessed.
#'
#'   PRD centers slightly above 1 and has a generally accepted value of between
#'   0.98 and 1.03, as defined in the
#'   \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
#'   Section 9.2.7. Higher PRD values indicate regressivity in assessment.
#'
#'   NOTE: The IAAO recommends trimming outlier ratios before calculating PRD,
#'   as it is extremely sensitive to large outliers. PRD is being deprecated in
#'   favor of PRB, which is less sensitive to outliers and easier to interpret.
#'
#' @param estimate A numeric vector of assessed values. Must be the same
#'   length as \code{sale_price}.
#' @param sale_price A numeric vector of sale prices. Must be the same length
#'   as \code{estimate}.
#'
#' @inheritParams cod
#' @describeIn prd Returns a numeric vector containing the PRD of the
#'   input vectors.
#' @order 1
#'
#' @examples
#' # Calculate PRD
#' prd(ratios_sample$estimate, ratios_sample$sale_price)
#' @family formulas
#' @export
prd <- function(estimate, sale_price, na.rm = FALSE) {
  # nolint end

  check_inputs(estimate, sale_price)
  idx <- index_na(estimate, sale_price)
  if (na.rm) {
    estimate <- estimate[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  # Calculate ratio of assessed values to sale price
  ratio <- estimate / sale_price

  # Calculate PRD
  prd <- mean(ratio) / stats::weighted.mean(ratio, sale_price)

  return(prd)
}



##### PRB #####

# Calculate PRB and return model object
calc_prb <- function(estimate, sale_price) {
  ratio <- estimate / sale_price
  med_ratio <- stats::median(ratio)
  lhs <- (ratio - med_ratio) / med_ratio
  rhs <- log(((estimate / med_ratio) + sale_price) * 0.5) / log(2)
  prb_model <- stats::lm(formula = lhs ~ rhs)

  return(prb_model)
}


# nolint start
#' Calculate Coefficient of Price-Related Bias (PRB)
#'
#' @description PRB is an index of vertical equity that quantifies the
#'   relationship betweem ratios and assessed values as a percentage. In
#'   concrete terms, a PRB of 0.02 indicates that, on average, ratios increase
#'   by 2\% whenever assessed values increase by 100 percent.
#'
#'   PRB is centered around 0 and has a generally accepted value of between
#'   -0.05 and 0.05, as defined in the
#'   \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
#'   Section 9.2.7. Higher PRB values indicate progressivity in assessment,
#'   while negative values indicate regressivity.
#'
#'   NOTE: PRB is significantly less sensitive to outliers than PRD or COD.
#'
#' @inheritParams prd
#' @describeIn prb Returns a numeric vector containing the PRB of the
#'   input vectors.
#' @order 1
#'
#' @examples
#' # Calculate PRB
#' prb(ratios_sample$estimate, ratios_sample$sale_price)
#' @family formulas
#' @export
prb <- function(estimate, sale_price, na.rm = FALSE) {
  # nolint end

  check_inputs(estimate, sale_price)

  idx <- index_na(estimate, sale_price)
  if (na.rm) {
    estimate <- estimate[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  # Calculate PRB
  prb_model <- calc_prb(estimate, sale_price)

  # Extract PRB from model
  prb <- unname(stats::coef(prb_model)[2])

  return(prb)
}



##### MKI_KI #####

# Calculate the Gini cofficients needed for KI and MKI
calc_gini <- function(estimate, sale_price) {
  df <- data.frame(av = estimate, sp = sale_price)
  df <- df[order(df$sp), ]
  assessed_price <- df$av
  sale_price <- df$sp
  n <- length(assessed_price)

  av_sum <- sum(assessed_price * seq_len(n))
  g_estimate <- 2 * av_sum / sum(assessed_price) - (n + 1L)
  gini_estimate <- g_estimate / n

  sale_sum <- sum(sale_price * seq_len(n))
  g_sale <- 2 * sale_sum / sum(sale_price) - (n + 1L)
  gini_sale <- g_sale / n

  result <- list(gini_estimate = gini_estimate, gini_sale = gini_sale)

  return(result)
}


# nolint start
#' Calculate Kakwani and Modified Kakwani Index
#'
#' @description The Kakwani Index (KI) and the Modified Kakwani Index (MKI)
#'   are Gini-based methods to measure vertical equity.
#'
#'   These methods first order properties by sale price (ascending), then
#'   calculate the Gini coefficient for sale values and assessed values (while
#'   remaining ordered by sale price). The Kakwani Index then
#'   calculates the difference \code{(Gini of assessed - Gini of sale)}, and the
#'   Modified Kakwani Index calculates the ratio
#'   \code{(Gini of Assessed / Gini of Sale)}.
#'
#'   For the Kakwani Index:
#'
#'   - KI < 0 is regressive
#'   - KI = 0 is vertical equity
#'   - KI > 0 is progressive
#'
#'   For the Modified Kakwani Index:
#'
#'   - MKI < 1 is regressive
#'   - MKI = 1 is vertical equity
#'   - MKI > 1 is progressive
#'
#' @references
#'   Quintos, C. (2020). A Gini measure for vertical equity in property
#'   assessments. Journal of Property Tax Assessment & Administration, 17(2).
#'   Retrieved from \href{https://researchexchange.iaao.org/jptaa/vol17/iss2/2}{https://researchexchange.iaao.org/jptaa/vol17/iss2/2}.
#'
#'   Quintos, C. (2021). A Gini decomposition of the sources of inequality in
#'   property assessments. Journal of Property Tax Assessment & Administration,
#'   18(2). Retrieved from
#'  \href{https://researchexchange.iaao.org/jptaa/vol18/iss2/6}{https://researchexchange.iaao.org/jptaa/vol18/iss2/6}
#'
#' @inheritParams prd
#' @describeIn mki_ki Returns a numeric vector containing the KI of the
#'   input vectors.
#' @order 2
#'
#' @examples
#'
#' # Calculate KI
#' ki(ratios_sample$estimate, ratios_sample$sale_price)
#' @family formulas
#' @export
#' @md
ki <- function(estimate, sale_price, na.rm = FALSE) {
  # nolint end

  check_inputs(estimate, sale_price)

  idx <- index_na(estimate, sale_price)
  if (na.rm) {
    estimate <- estimate[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  g <- calc_gini(estimate, sale_price)
  ki <- g$gini_estimate - g$gini_sale

  return(ki)
}

#' @inheritParams prd
#' @describeIn mki_ki Returns a numeric vector containing the MKI of the
#'   input vectors.
#' @order 1
#'
#' @examples
#' # Calculate MKI
#' mki(ratios_sample$estimate, ratios_sample$sale_price)
#' @export
mki <- function(estimate, sale_price, na.rm = FALSE) {
  check_inputs(estimate, sale_price)

  idx <- index_na(estimate, sale_price)
  if (na.rm) {
    estimate <- estimate[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  g <- calc_gini(estimate, sale_price)
  mki <- g$gini_estimate / g$gini_sale

  return(mki)
}



##### STANDARDS #####

# Mini functions to test if IAAO standards are met

#' @describeIn cod Returns TRUE when input COD meets IAAO standards
#'   (between 5 and 15).
#' @param x Numeric vector of sales ratio statistic(s) to check
#'   against IAAO/Quintos standards.
#' @export
cod_met <- function(x) x >= 5.00 & x <= 15

#' @describeIn prd Returns TRUE when input PRD meets IAAO standards
#'   (between 0.98 and 1.03).
#' @inheritParams cod_met
#' @export
prd_met <- function(x) x >= 0.98 & x <= 1.03

#' @describeIn prb Returns TRUE when input PRB meets IAAO standards
#'   (between -0.05 and 0.05).
#' @inheritParams cod_met
#' @export
prb_met <- function(x) x >= -0.05 & x <= 0.05

#' @describeIn mki_ki Returns TRUE when input meets Quintos paper standards
#'   (between 0.95 and 1.05).
#' @inheritParams cod_met
#' @export
mki_met <- function(x) x >= 0.95 & x <= 1.05
