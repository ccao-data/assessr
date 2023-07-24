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
#'
#' # Calculate COD
#' cod(ratios_sample$ratio)
#' @family formulas
#' @export
cod <- function(ratio, na.rm = FALSE) {
  # nolint end

  # Input checking and error handling
  check_inputs(ratio)

  # Remove NAs if na.rm = TRUE
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
#'
#' # Calculate PRD
#' prd(ratios_sample$assessed, ratios_sample$sale_price)
#' @family formulas
#' @export
prd <- function(assessed, sale_price, na.rm = FALSE) {
  # nolint end

  # Input checking and error handling
  check_inputs(assessed, sale_price)

  # Remove NAs from input vectors. Otherwise, return NA if the input vectors
  # contain any NA values
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

  return(prd)
}



##### PRB #####

# Calculate PRB and return model object
calc_prb <- function(assessed, sale_price) {
  # Calculate ratio of assessed values to sale price
  ratio <- assessed / sale_price

  # Calculate median ratio
  med_ratio <- stats::median(ratio)

  # Generate left-hand side of PRB regression
  lhs <- (ratio - med_ratio) / med_ratio # nolint

  # Generate right-hand side of PRB regression
  rhs <- log(((assessed / med_ratio) + sale_price) * 0.5) / log(2) # nolint

  # Calculate PRB and create model object
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
#' @describeIn prb Returns a numeric vector containing the PRD of the
#'   input vectors.
#' @order 1
#'
#' @examples
#'
#' # Calculate PRD
#' prb(ratios_sample$assessed, ratios_sample$sale_price)
#' @family formulas
#' @export
prb <- function(assessed, sale_price, na.rm = FALSE) {
  # nolint end

  # Input checking and error handling
  check_inputs(assessed, sale_price)

  # Remove NAs from input vectors. Otherwise, return NA if the input vectors
  # contain any NA values
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

  return(prb)
}






##### GINI Measure for Vertical Equity #####

#' @description The GINI Measure for Vertical Equity is a mechanism to identify difference in inequality for
#' assessed and sale value of houses. It uses the GINI coefficient to identify the inequality of housing prices,
#' and then identifies the distribution of assessed value as housing prices ascend. This produces two GINI
#' coefficients, both of which are ordered in accordance with sales price. From these coefficients, two metrics are
#' produced, the Kakwani Index (KI), which is the GINI coefficient of the assessed value - the GINI coefficient of the sale value.
#' The second is the Modified Kakwani Index (MKI), which is the GINI coefficient of the assessed value / the GINI coefficient of the sale
#' value. The Modified Kakwani index is a better metric when working across different neighborhoods with different
#' distributions of sale values.
#'
#'
#' For KI, a negative value represents a regressive assessment structure, and a positive value represents a progressive assessment structure.
#' For MKI, a ratio < 1 represents a regressive assessment structure and > 1 represents a progressive assessment structure
#'
#'
#'   \href{Quintos Ph D, Carmela. "A Gini measure for vertical equity in property assessments." Journal of Property Tax Assessment & Administration 17.2 (2020): 2.20}
#'
#'
#'@inheritParams cod
#' @describeIn Returns a list of two results, the MKI and the KI.
#'
#'
#' @param assessed vector or row of assessed values with same length as \code{sale_price}
#' @param sale_price vector or row of sale values with same length as \code{assessed}
#'


#'
#' @order 1
#'
#'
#' @family formulas
#' @export



#' @examples
#' # example code
#' Vertical_Gini(ratios_sample$assessed, ratios_sample$sale_price)




KI_MKI <- function(assessed, sale) {


  # Input checking and error handling
  check_inputs(assessed, sale_price)

  # Remove NAs from input vectors. Otherwise, return NA if the input vectors
  # # contain any NA values
  # idx <- index_na(assessed, sale_price)
  # if (na.rm) {
  #   assessed <- assessed[!idx]
  #   sale_price <- sale_price[!idx]
  # } else if (any(idx) && !na.rm) {
  #   return(NA_real_)
  # }

  # Ensure data is arranged in ascending order

  dataset <- data.frame(sale = sale, assessed = assessed)
  dataset <- dataset %>%
    arrange(sale)

  # Reassigns information into objects
  assessed_price <- dataset$assessed
  sale_price <- dataset$sale

  # Creates vector with the length of data set
  n <- length(assessed_price)

  #   Calculate the sum of the first n elements of assessed_price vector.
  G_assessed <- sum(assessed_price * 1L:n)

  #Compute Gini Coefficient:
  G_assessed <- 2 * G_assessed/sum(assessed_price) - (n + 1L)

  # Normalize the Gini coefficient by dividing it by n.
  GINI_assessed <- G_assessed/n



  # Same process for Sale
  G_sale <- sum(sale_price * 1L:n)

  G_sale <- 2 * G_sale/sum(sale_price) - (n + 1L)

  GINI_sale <- G_sale/n

  # Calculate the MKI
  MKI <- GINI_assessed / GINI_sale

  # Calculate KI
  KI <- GINI_assessed - GINI_sale

  #Return Output
  result <- list(MKI = MKI, KI = KI)

  return(result)
}



# TO TEST GINI:
# Gini(combined$sale_price)





##### STANDARDS #####

# Mini functions to test if IAAO standards are met

#' @describeIn cod Returns TRUE when input COD meets IAAO standards
#'   (between 5 and 15).
#' @param x Numeric vector of sales ratio statistic(s) to check
#'   against IAAO standards.
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
