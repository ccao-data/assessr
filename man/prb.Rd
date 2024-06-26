% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/formulas.R, R/ci.R
\name{prb}
\alias{prb}
\alias{prb_ci}
\alias{prb_met}
\title{Calculate Coefficient of Price-Related Bias (PRB)}
\usage{
prb(assessed, sale_price, na.rm = FALSE)

prb_ci(assessed, sale_price, alpha = 0.05, na.rm = FALSE)

prb_met(x)
}
\arguments{
\item{assessed}{A numeric vector of assessed values. Must be the same
length as \code{sale_price}.}

\item{sale_price}{A numeric vector of sale prices. Must be the same length
as \code{assessed}.}

\item{na.rm}{Default FALSE. A boolean value indicating whether or not to
remove NA values. If missing values are present but not removed the
function will output NA.}

\item{alpha}{Default 0.05. Numeric value indicating the confidence
interval to return. 0.05 will return the 95\% confidence interval.}

\item{x}{Numeric vector of sales ratio statistic(s) to check
against IAAO/Quintos standards.}
}
\description{
PRB is an index of vertical equity that quantifies the
  relationship between ratios and assessed values as a percentage. In
  concrete terms, a PRB of 0.02 indicates that, on average, ratios increase
  by 2\% whenever assessed values increase by 100 percent.

  PRB is centered around 0 and has a generally accepted value of between
  -0.05 and 0.05, as defined in the
  \href{https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf}{IAAO Standard on Ratio Studies}
  Section 9.2.7. Higher PRB values indicate progressivity in assessment,
  while negative values indicate regressivity.

  NOTE: PRB is significantly less sensitive to outliers than PRD or COD.
}
\section{Functions}{
\itemize{
\item \code{prb()}: Returns a numeric vector containing the PRB of the
input vectors.

\item \code{prb_ci()}: Returns upper and lower CI as a named vector.

\item \code{prb_met()}: Returns TRUE when input PRB meets IAAO standards
(between -0.05 and 0.05).

}}
\examples{
# Calculate PRB
prb(ratios_sample$assessed, ratios_sample$sale_price)

# Calculate PRD confidence interval
prb_ci(ratios_sample$assessed, ratios_sample$sale_price)
}
\seealso{
Other formulas: 
\code{\link{cod}()},
\code{\link{mki}()},
\code{\link{prd}()}
}
\concept{formulas}
