#' Calculate Coefficient of Dispersion (COD)
#'
#' @description COD is the average absolute percent deviation from the
#'   median ratio. It is a measure of horizontal equity, meaning that 
#'   properties with a similar fair market value should be similarly assessed.
#'   
#'   Lower COD indicates higher uniformity/horizontal equity in assessment.
#'   The IAAO sets uniformity standards that define generally accepted ranges
#'   for COD depending on property class. See 
#'   \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
#'   Page 17, Table 1.3 for a full list of standard COD ranges.
#'   
#'   NOTE: The IAAO recommends trimming the input vector before calculating COD,
#'   as it is extremely sensitive to large outliers. The typical method used is
#'   dropping values beyond 3 * IQR (inner-quartile range). See 
#'   \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
#'   Appendix B.1.
#' 
#' @param ratios A numeric vector of ratios centered around 1, where the 
#'   numerator of the ratio is the estimated fair market value and the
#'   denominator is the actual sale price. 
#' @param na.rm Default FALSE. A boolean value indicating whether or not to 
#'   remove NA values. If missing values are present but not removed the 
#'   function will output NA.
#'   
#' @return A numeric vector containing the COD of \code{ratios}.
#'
#' @examples
#' 
#' # Load the included dataset
#' data("ratios_sample")
#' cod(ratios_sample$ratio)
#' 
#' @family formulas
#' @export
cod <- function(ratios, na.rm = FALSE) {

  # Input checking and error handling
  stopifnot(
    length(ratios) > 1, # length of input gt 1
    is.vector(ratios), # Input is vector
    is.numeric(ratios), # Input is numeric
    !is.nan(ratios), # No NaNs in input
    is.logical(na.rm) # Must be logical
  )

  # Remove NAs if na.rm = TRUE
  if(na.rm) ratios <- stats::na.omit(ratios)
  
  # Calculate median ratio
  med <- stats::median(ratios)
  
  # Calculate COD 
  cod <- (mean(abs(ratios - med)) / med) * 100
  
  return(cod)
}
