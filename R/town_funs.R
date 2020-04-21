#' Convert between township number and township name
#'
#' Convert township name to its respective two-digit code and visa-versa.
#'
#' @param town Vector of township names or numeric codes. Township name
#'   must be title case to match correctly.
#'
#' @return Vector or township codes or names equivalent to the input vector.
#'   Returns NA for towns that cannot be found.
#'
#' @examples
#'
#' town_convert("Evanston")
#'
#' town_convert(c("31", "25"))
#'
#' town_convert(c("31", "Proviso", "Lyons"))
#' @export
town_convert <- function(town) {

  # Input error handling
  stopifnot(
    is.vector(town), # input must be vector
    is.character(town) # input must be character
  )

  # Return town name for two digit numeric codes and numeric codes
  # for town name
  out <- ifelse(nchar(town) != 2 & !is.na(is.numeric(town)),
    as.character(assessr::town_dict$township_code[
      match(town, assessr::town_dict$township_name)
    ]),
    as.character(assessr::town_dict$township_name[
      match(town, assessr::town_dict$township_code)
    ])
  )

  return(out)
}


#' Get Cook County triad name or number based on township name or code
#'
#' Get the triad name or number based on township name or code.
#' Cook County is split into three sections called triads. These triads are
#' assessed every three years. Each town lies entirely within a single triad.
#'
#' @inheritParams town_convert
#'
#' @param name Default FALSE. Output triad name instead of triad number.
#'
#' @return Vector of triad numbers for the input townships. Returns NA for
#'   towns that cannot be found.
#'
#' @examples
#'
#' town_get_triad("Evanston")
#'
#' town_get_triad(c("Lyons", "10", "Worth"))
#' @export
town_get_triad <- function(town, name = FALSE) {

  # Input error handling
  stopifnot(
    is.vector(town), # input must be vector
    is.character(town), # input must be character
    is.logical(name)
  )

  # Return triad name if name = TRUE, otherwise return triad numeric code
  if (name) {
    out <- ifelse(nchar(town) != 2 & !is.na(is.numeric(town)),
      as.character(assessr::town_dict$triad_name[
        match(town, assessr::town_dict$township_name)
      ]),
      as.character(assessr::town_dict$triad_name[
        match(town, assessr::town_dict$township_code)
      ])
    )
  } else {
    out <- ifelse(nchar(town) != 2 & !is.na(is.numeric(town)),
      as.character(assessr::town_dict$triad_code[
        match(town, assessr::town_dict$township_name)
      ]),
      as.character(assessr::town_dict$triad_code[
        match(town, assessr::town_dict$township_code)
      ])
    )
  }

  return(out)
}


#' Get the nearest assessment year of a township
#'
#' Input a township name or code and get the assessment year closest to the
#' year argument. Current year is the default. Will never return a year higher
#' than the current year.
#'
#' Ex. \code{town_get_assmnt_year("Evanston")} outputs \code{2019}
#'
#' @inheritParams town_convert
#'
#' @param year Default current year. Year to find assessment year closest to.
#'   For example, entering 1995 will find the closest assessment year to 1995
#'   for all the entered triads.
#'
#' @return Numeric vector of assessment years closest to the year entered.
#'   Returns NA for towns that cannot be found.
#'
#' @examples
#'
#' town_get_assmnt_year("Evanston")
#'
#' town_get_assmnt_year(c("Lyons", "10", "Worth"), year = 1997)
#' @export
town_get_assmnt_year <- function(town,
                                 year = as.integer(format(Sys.Date(), "%Y"))) {

  # Input error handling
  stopifnot(
    is.vector(town), # input must be vector
    is.character(town), # input must be character
    is.numeric(year), # year must be numeric
    year >= 1991, # year must be greater than 1991
    year <= as.integer(format(Sys.Date(), "%Y")) # year must be less than now
  )

  # Get the triad of the entered town(s)
  triads <- town_get_triad(town)

  # Create a vector of years, starting in 1991. Use this vector to create a
  # dataframe of years and the triad evaluated in each year.
  years <- 1991:(as.integer(format(Sys.Date(), "%Y")))
  years_df <- data.frame(
    year = years,
    triad = rep_len(1:3, length(years))
  )

  # For each triad in the input list, get the years they were assessessed,
  # between 1991 and the current year
  years_for_this_triad <- lapply(
    triads,
    function(x) years_df[which(years_df$triad == x), 1]
  )

  # Lookup the nearest year to the one entered for each of the given triads
  out <- as.numeric(sapply(
    years_for_this_triad,
    function(x) x[which.min(abs(x - year))]
  ))

  return(out)
}
