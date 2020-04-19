#' Data dictionary for CCAO township codes and triads.
#'
#' A dataset containing a lookup of various townships and their
#' respective triads.
#'
#' @format A data frame with 38 rows and 4 variables:
#' \describe{
#'   \item{township_name}{Common name of the township}
#'   \item{township_code}{Two-digit code used to identify the township}
#'   \item{triad_code}{Single-digit code of the triad the township is in}
#'   \item{triad_name}{Common name of the triad the township is in}
#' }
#'
"town_dict"


#' Data dictionary for CCAO characteristic values.
#'
#' A dataset containing human-readable version of numeric characteristic
#' encodings of property characteristic data.
#'
#' @format A data frame with 61 rows and 4 variables:
#' \describe{
#'   \item{char_name}{Column name of variable in CCAO SQL server}
#'   \item{char_code}{Value code used in CCAO SQL server and in paper forms}
#'   \item{char_value}{Actual meaning of char_code}
#'   \item{char_value_short}{Actual meaning of char_code, shortened}
#' }
#'
#' @source This dictionary was manually created from paper forms as a
#'   translation of numeric variables. char_value_short is the equivalent of
#'   what is used on the AS400 property info screens
"chars_dict"


#' Data dictionary of Cook County property classes.
#'
#' A dataset containing a translation for residential class codes to
#' human-readable class descriptions.
#'
#' @format A data frame with 15 rows and 2 variables:
#' \describe{
#'   \item{class_code}{Class code, numeric}
#'   \item{desc}{Human-readable description of the property class}
#' }
#'
#' @note Only includes residential classes.
"class_dict"


#' Codes used by the CCAO to identify certain distinct property situations.
#'
#' A dataset containing a lookup of CDU codes. These codes are kind of a mess
#' and have been created and used inconsistently over the years.
#'
#' @format A data frame with 28 rows and 4 variables:
#' \describe{
#'   \item{cdu_code}{Common name of the township}
#'   \item{cdu_type}{Two-digit code used to identify the township}
#'   \item{cdu_value}{Actual meaning of CDU code}
#'   \item{cdu_value_short}{Actual meaning of CDU code, shortened}
#' }
#'
"cdu_dict"


#' Sample of ratio and sales data used by the CCAO to evaluate assessment
#' performance.
#'
#' This sample was take from Evanston and New Trier in 2019. Ratios are
#' calculated using assessor certified (post-appeal) values.
#'
#' @format A data frame with 2979 observation and 4 variables:
#' \describe{
#'   \item{ratios}{Sales ratio representing assessed value / sale price}
#'   \item{sales}{The recorded sale price of this property}
#'   \item{town}{Township name the property is in}
#'   \item{assessed_values}{The value predicted by CCAO assessment models,
#'   including any appeals have been applied}
#' }
#'
"ratios_sample"
