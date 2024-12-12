#' Sample of ratio and sales data pulled from CCAO records
#'
#' This sample was take from Evanston and New Trier in 2019. Ratios are
#' calculated using assessor certified (post-appeal) fair market values.
#'
#' @format A data frame with 979 observation and 3 variables:
#' \describe{
#'   \item{estimate}{The fair market assessed value predicted by CCAO assessment
#'     models, including any successful appeals}
#'   \item{sale_price}{The recorded sale price of this property}
#'   \item{town}{Township name the property is in}
#' }
#'
"ratios_sample"

#' Sample of sales and estimated market values provided by Quintos in the
#'    following MKI papers:
#'
#' @references
#' Quintos, C. (2020). A Gini measure for vertical equity in property
#' assessments. <https://researchexchange.iaao.org/jptaa/vol17/iss2/2>
#'
#' Quintos, C. (2021). A Gini decomposition of the sources of inequality in
#' property assessments. <https://researchexchange.iaao.org/jptaa/vol18/iss2/6>
#'
#' @format A data frame with 30 observation and 2 variables:
#' \describe{
#'   \item{estimate}{Assessed fair market value}
#'   \item{sale_price}{Recorded sale price of this property}
#' }
#'
"quintos_sample"
