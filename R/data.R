#' Sample of ratio and sales data pulled from CCAO records.
#'
#' This sample was take from Evanston and New Trier in 2019. Ratios are
#' calculated using assessor certified (post-appeal) fair market values.
#'
#' @format A data frame with 979 observation and 4 variables:
#' \describe{
#'   \item{assessed}{The fair market assessed value predicted by CCAO assessment
#'     models, including any successful appeals}
#'   \item{sale_price}{The recorded sale price of this property}
#'   \item{ratio}{Sales ratio representing fair market value / sale price}
#'   \item{town}{Township name the property is in}
#' }
#'
"ratios_sample"
