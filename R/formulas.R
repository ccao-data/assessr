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
#' @param ratio A numeric vector of ratios centered around 1, where the
#'   numerator of the ratio is the estimated fair market value and the
#'   denominator is the actual sale price.
#' @param na.rm Default FALSE. A boolean value indicating whether or not to
#'   remove NA values. If missing values are present but not removed the
#'   function will output NA.
#'
#' @describeIn cod Returns a numeric vector containing the COD of \code{ratios}.
#' @order 1
#'
#' @examples
#' # Calculate COD
#' cod(ratios_sample$ratio)
#' @family formulas
#' @export
cod <- function(ratio, na.rm = FALSE) {
  # nolint end

  check_inputs(ratio)
  if (na.rm) ratio <- stats::na.omit(ratio)

  # Calculate median ratio
  med_ratio <- stats::median(ratio)

  # Calculate COD
  cod <- (mean(abs(ratio - med_ratio)) / med_ratio) * 100

  cod
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
#' @param assessed A numeric vector of assessed values. Must be the same
#'   length as \code{sale_price}.
#' @param sale_price A numeric vector of sale prices. Must be the same length
#'   as \code{assessed}.
#'
#' @inheritParams cod
#' @describeIn prd Returns a numeric vector containing the PRD of the
#'   input vectors.
#' @order 1
#'
#' @examples
#' # Calculate PRD
#' prd(ratios_sample$assessed, ratios_sample$sale_price)
#' @family formulas
#' @export
prd <- function(assessed, sale_price, na.rm = FALSE) {
  # nolint end

  check_inputs(assessed, sale_price)
  idx <- index_na(assessed, sale_price)
  if (na.rm) {
    assessed <- assessed[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  # Calculate ratio of assessed values to sale price
  ratio <- assessed / sale_price

  # Calculate PRD
  prd <- mean(ratio) / stats::weighted.mean(ratio, sale_price)

  prd
}


##### PRB #####

# Calculate PRB and return model object
calc_prb <- function(assessed, sale_price) {
  ratio <- assessed / sale_price
  med_ratio <- stats::median(ratio)
  lhs <- (ratio - med_ratio) / med_ratio
  rhs <- log(((assessed / med_ratio) + sale_price) * 0.5) / log(2)
  prb_model <- stats::lm(formula = lhs ~ rhs)

  prb_model
}


# nolint start
#' Calculate Coefficient of Price-Related Bias (PRB)
#'
#' @description PRB is an index of vertical equity that quantifies the
#'   relationship between ratios and assessed values as a percentage. In
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
#' prb(ratios_sample$assessed, ratios_sample$sale_price)
#' @family formulas
#' @export
prb <- function(assessed, sale_price, na.rm = FALSE) {
  # nolint end

  check_inputs(assessed, sale_price)

  idx <- index_na(assessed, sale_price)
  if (na.rm) {
    assessed <- assessed[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  # Calculate PRB
  prb_model <- calc_prb(assessed, sale_price)

  # Extract PRB from model
  prb <- unname(stats::coef(prb_model)[2])

  prb
}


##### MKI_KI #####

# Calculate the Gini cofficients needed for KI and MKI
calc_gini <- function(assessed, sale_price) {
  df <- data.frame(av = assessed, sp = sale_price)
  # This Gini coefficient algorithm is sensitive to the order of the input
  # observations: If multiple observations share the same sale price but have
  # different estimates, the output coefficients will be different depending
  # on which of the sales with identical prices gets ordered first in the
  # input dataframe. To ensure a stable sort order, Quintos recommends
  # sorting by ascending sale price and then by descending estimate to break
  # any ties. This produces "worst case" MKI/KI statistics, but ensures those
  # statistics are deterministic. See this issue for more discussion:
  # https://github.com/ccao-data/assesspy/issues/33#issuecomment-3180632954
  df <- df[order(df$sp, -df$av), ]
  assessed_price <- df$av
  sale_price <- df$sp
  n <- length(assessed_price)

  av_sum <- sum(assessed_price * seq_len(n))
  g_assessed <- 2 * av_sum / sum(assessed_price) - (n + 1L)
  gini_assessed <- g_assessed / n

  sale_sum <- sum(sale_price * seq_len(n))
  g_sale <- 2 * sale_sum / sum(sale_price) - (n + 1L)
  gini_sale <- g_sale / n

  result <- list(gini_assessed = gini_assessed, gini_sale = gini_sale)

  result
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
#' ki(ratios_sample$assessed, ratios_sample$sale_price)
#' @family formulas
#' @export
#' @md
ki <- function(assessed, sale_price, na.rm = FALSE) {
  # nolint end

  check_inputs(assessed, sale_price)

  idx <- index_na(assessed, sale_price)
  if (na.rm) {
    assessed <- assessed[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  g <- calc_gini(assessed, sale_price)
  ki <- g$gini_assessed - g$gini_sale

  ki
}

#' @inheritParams prd
#' @describeIn mki_ki Returns a numeric vector containing the MKI of the
#'   input vectors.
#' @order 1
#'
#' @examples
#' # Calculate MKI
#' mki(ratios_sample$assessed, ratios_sample$sale_price)
#' @export
mki <- function(assessed, sale_price, na.rm = FALSE) {
  check_inputs(assessed, sale_price)

  idx <- index_na(assessed, sale_price)
  if (na.rm) {
    assessed <- assessed[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  g <- calc_gini(assessed, sale_price)
  mki <- g$gini_assessed / g$gini_sale

  mki
}


##### VEI #####

# Assign each observation (sorted by market value proxy) to a quantile group
# using the IAAO R7 ranking method. Returns a vector of group numbers
calc_vei_groups <- function(n, group_n) {
  i <- seq_len(group_n)
  pos <- floor(i * (n - 1) / group_n + 1)

  rep(i, times = diff(c(0, pos)))
}


# Calculate VEI and its components. Returns a list containing the VEI point
# estimate, the VEI confidence interval, and per-quantile group statistics
calc_vei <- function(assessed, sale_price, alpha = 0.10) {
  stopifnot(
    is.numeric(alpha),
    length(alpha) == 1,
    alpha > 0 && alpha < 1
  )

  ratio <- assessed / sale_price
  sample_median <- stats::median(ratio)
  n <- length(ratio)

  # VEI requires at least 2 groups of 10 sales
  if (n < 20) {
    warning("VEI requires at least 20 observations, returning NA")
    return(list(vei = NA_real_, ci = c(NA_real_, NA_real_), groups = NULL))
  }

  # Market value proxy that gives equal weight to sale price and
  # median-adjusted assessed value. This is the same proxy used by PRB
  proxy <- 0.5 * sale_price + 0.5 * (assessed / sample_median)

  # Number of quantile groups depends on sample size
  group_n <- if (n >= 501) {
    10L
  } else if (n >= 51) {
    4L
  } else {
    2L
  }

  # Sort ratios by proxy and split into quantile groups
  ratio <- ratio[order(proxy)]
  groups <- split(ratio, calc_vei_groups(n, group_n))
  group_n_obs <- lengths(groups)
  group_median <- vapply(groups, stats::median, numeric(1))

  # VEI is the difference between the last and first quantile group medians
  # as a percentage of the overall sample median
  median_diff <- group_median[group_n] - group_median[1]
  vei <- 100 * median_diff / sample_median

  # Standard error of the log median ratio for each group, converted back to
  # the raw scale. sqrt(pi / 2) is the asymptotic efficiency of the median
  # relative to the mean
  group_se <- vapply(
    groups,
    function(x) sqrt(pi / 2) * stats::sd(log(x)) / sqrt(length(x)),
    numeric(1)
  ) * group_median

  # Combine the standard errors of the first and last groups, then construct
  # the VEI confidence interval
  se_diff <- sqrt(group_se[1]^2 + group_se[group_n]^2)
  z <- stats::qnorm(1 - alpha / 2)
  ci <- 100 * (median_diff + c(-1, 1) * z * se_diff) / sample_median

  list(
    vei = unname(vei),
    ci = unname(ci),
    groups = data.frame(
      group = seq_len(group_n),
      n = unname(group_n_obs),
      median_ratio = unname(group_median),
      se = unname(group_se),
      row.names = NULL
    )
  )
}


# nolint start
#' Calculate Vertical Equity Indicator (VEI)
#'
#' @description VEI is the primary measure of vertical equity in the 2026
#'   IAAO Standard on Ratio Studies (Section 8.2 and Appendix E). It compares
#'   the median ratio of the lowest-value properties to the median ratio of
#'   the highest-value properties.
#'
#'   VEI is calculated as follows:
#'
#'   1. Compute a ratio for each observation (assessed / sale price).
#'   2. Compute a market value proxy for each observation that gives equal
#'      weight to the sale price and the assessed value divided by the
#'      overall median ratio. This is the same proxy used by [prb()].
#'   3. Sort observations by the proxy and split them into quantile groups:
#'      10 groups for 501+ observations, 4 groups for 51-500, and 2 groups
#'      for 20-50.
#'   4. Subtract the first quantile group's median ratio from the last
#'      quantile group's median ratio, divide by the overall median ratio,
#'      and multiply by 100.
#'
#'   VEI is centered around 0 and has a generally accepted value of between
#'   -10 and 10. Negative values indicate regressivity in assessment, while
#'   positive values indicate progressivity.
#'
#'   A VEI outside of the acceptable range should be tested for statistical
#'   significance using [vei_ci()]. The confidence interval is built from the
#'   standard errors of the log median ratios of the first and last quantile
#'   groups. If the confidence interval overlaps the -10 to 10 range, the VEI
#'   is still considered acceptable. See [vei_met()].
#'
#'   When the number of observations does not divide evenly into groups,
#'   observations are assigned using the IAAO's R7 ranking method (Appendix
#'   E.5), which is the method used in the IAAO's worked example and matches
#'   `type = 7` in [stats::quantile()].
#'
#'   NOTE: VEI requires at least 20 observations (10 per group). Smaller
#'   samples return `NA` with a warning.
#'
#' @inheritParams prd
#' @describeIn vei Returns a numeric vector containing the VEI of the
#'   input vectors.
#' @order 1
#'
#' @examples
#' # Calculate VEI
#' vei(ratios_sample$assessed, ratios_sample$sale_price)
#' @family formulas
#' @export
#' @md
vei <- function(assessed, sale_price, na.rm = FALSE) {
  # nolint end

  check_inputs(assessed, sale_price)

  idx <- index_na(assessed, sale_price)
  if (na.rm) {
    assessed <- assessed[!idx]
    sale_price <- sale_price[!idx]
  } else if (any(idx) && !na.rm) {
    return(NA_real_)
  }

  calc_vei(assessed, sale_price)$vei
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

#' @describeIn vei Returns TRUE when input VEI meets IAAO standards
#'   (between -10 and 10). If \code{ci} is supplied, also returns TRUE when
#'   the VEI is outside this range but its confidence interval overlaps it.
#' @inheritParams cod_met
#' @param ci Optional. A two-long numeric vector containing the lower and
#'   upper VEI confidence limits, as returned by \code{vei_ci()}.
#' @export
vei_met <- function(x, ci = NULL) {
  if (is.null(ci)) {
    return(x >= -10 & x <= 10)
  }
  stopifnot(is.numeric(ci), length(ci) == 2)

  (x >= -10 & x <= 10) | (ci[1] <= 10 & ci[2] >= -10)
}

##### Median_ratio_met #####

#' Check if Sales Ratio Meets IAAO Standards
#'
#' This function checks whether the input sales ratio falls within
#' the IAAO standard range (0.9 to 1.1).
#'
#' @param x Numeric vector of sales ratios. The function does not calculate any
#'   medians, and instead assumes that vector elements already represent
#'   median ratios.
#' @return Logical vector indicating whether each value meets the standard.
#' @export
med_ratio_met <- function(x) x >= 0.9 & x <= 1.1
