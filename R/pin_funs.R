#' Clean input parameter values
#'
#' This function removes common separators, whitespace, and trailing characters
#' from Property Index Numbers (PINs). It is specifically formatted for PINs,
#' which are expected to be 10 or 14 digit numbers saved as characters (to
#' allow for leading zeros).
#'
#' @param x A Property Index Number (PIN) containing unnecessary whitespace
#'   or separator characters
#'
#' @return A clean PIN character vector with no whitespace or separators.
#'
#' @examples
#'
#' pins <- c("04-34-106-008-0000", " 14172 27008 0000")
#'
#' pin_clean(pins)
#' @export
pin_clean <- function(x) {

  # Error handling. Warn if not character or if contains non-numeric
  if (!is.character(x) | !is.vector(x)) {
    warning("Input PIN(s) are not a character vector.")
  } else if (sum(grepl("[a-z]", x)) & is.character(x)) {
    warning("Input PIN(s) contain alphabetical characters.")
  }

  # Remove separators and quotes
  out <- gsub(pattern = "-|'|\\\"", replacement = "", as.character(x))

  # Remove all whitespace
  out <- gsub(pattern = " ", replacement = "", out, fixed = TRUE)

  # Remove trailing and leading whitespace
  out <- trimws(out)

  return(out)
}
