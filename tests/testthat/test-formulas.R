# Load the ratios sample dataset for testing
data("ratios_sample")

# Extract the components of the dataframe as vectors
ratio <- ratios_sample$ratio
sale_price <- ratios_sample$sale_price
assessed <- ratios_sample$assessed

# Load example data from Quintos article
mki_ki_data <- read.csv(
  rprojroot::find_testthat_root_file("data/mki_ki_data.csv")
)

mki_ki_assessed <- mki_ki_data$Assessed
mki_ki_sale_price <- mki_ki_data$Sale_Price

mki_tiebreaks <- read.csv(
  rprojroot::find_testthat_root_file("data/mki_ki_data_with_tiebreaks.csv")
)

tiebreaks_Sale_Price <- mki_tiebreaks$Sale_Price
tiebreaks_Assessed <- mki_tiebreaks$Assessed
tiebreaks_Assessed_alt_sort_1 <- mki_tiebreaks$Assessed_alt_sort_1
tiebreaks_Assessed_alt_sort_2 <- mki_tiebreaks$Assessed_alt_sort_2

# Load example VEI data from Table 10.1 of the 2026 IAAO Standard on Ratio
# Studies. Expected values come from Appendix E.6
vei_data <- read.csv(
  rprojroot::find_testthat_root_file("data/vei_data.csv")
)

vei_assessed <- vei_data$assessed_value
vei_sale_price <- vei_data$sale_price


##### TEST COD #####

# Calculate COD
cod_out <- cod(ratio)

test_that("returns numeric vector", {
  expect_type(cod_out, "double")
  expect_vector(cod_out)
})

test_that("output equal to expected", {
  expect_equal(cod_out, 17.81457, tolerance = 0.02)
})

test_that("bad input data stops execution", {
  expect_error(cod(numeric(0)))
  expect_error(cod(numeric(10)))
  expect_error(cod(c(cod_out, Inf)))
  expect_error(cod(data.frame(ratio)))
  expect_error(cod(c(ratio, NaN)))
  expect_error(cod(c(ratio, "2")))
  expect_error(cod(ratio, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(cod(c(ratio, NA)), NA_real_)
  expect_equal(cod(c(ratio, NA), na.rm = TRUE), 17.81457, tolerance = 0.02)
})

test_that("standard met function", {
  expect_false(cod_met(cod_out))
})


##### TEST PRD #####

# Calculate PRD
prd_out <- prd(assessed, sale_price)

test_that("returns numeric vector", {
  expect_type(prd_out, "double")
  expect_vector(prd_out)
})

test_that("output equal to expected", {
  expect_equal(prd_out, 1.048419, tolerance = 0.02)
})

test_that("bad input data stops execution", {
  expect_error(prd(numeric(0)))
  expect_error(prd(numeric(10), numeric(10)))
  expect_error(prd(c(prd_out, Inf), c(prb_out, 0)))
  expect_error(prd(assessed, c(sale_price, 10e5)))
  expect_error(prd(data.frame(assessed), sale_price))
  expect_error(prd(c(assessed, NaN), c(sale_price, 1)))
  expect_error(prd(c(assessed, "2"), c(sale_price, 1)))
  expect_error(prd(assessed, sale_price, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(
    prd(c(assessed, NA), c(sale_price, 10e5)),
    NA_real_
  )
  expect_equal(
    prd(c(assessed, NA), c(sale_price, 10e5), na.rm = TRUE),
    1.048419,
    tolerance = 0.02
  )
})

test_that("standard met function", {
  expect_false(prd_met(prd_out))
})


##### TEST PRB #####

# Calculate PRB
prb_out <- prb(assessed, sale_price)

test_that("returns expected type", {
  expect_type(prb_out, "double")
  expect_vector(prb_out)
})

test_that("output equal to expected", {
  expect_equal(prb_out, 0.0024757, tolerance = 0.02)
})

test_that("bad input data stops execution", {
  expect_error(prb(numeric(0)))
  expect_error(prb(numeric(10), numeric(10)))
  expect_error(prb(c(prb_out, Inf), c(prb_out, 0)))
  expect_error(prb(assessed, c(sale_price, 10e5)))
  expect_error(prb(data.frame(assessed), sale_price))
  expect_error(prb(c(assessed, NaN), c(sale_price, 1)))
  expect_error(prb(c(assessed, "2"), c(sale_price, 1)))
  expect_error(prb(assessed, sale_price, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(
    prb(c(assessed, NA), c(sale_price, 10e5)),
    NA_real_
  )
  expect_equal(
    prb(c(assessed, NA), c(sale_price, 10e5), na.rm = TRUE),
    0.0024757,
    tolerance = 0.02
  )
})

test_that("standard met function", {
  expect_true(prb_met(prb_out))
})


##### TEST MKI #####

# Calculate MKI
mki_out <- mki(mki_ki_assessed, mki_ki_sale_price)

test_that("returns expected type", {
  expect_type(mki_out, "double")
  expect_vector(mki_out)
})

test_that("output equal to expected", {
  expect_equal(mki_out, 0.79, tolerance = 0.01)
})

test_that("bad input data stops execution", {
  expect_error(mki(numeric(0)))
  expect_error(mki(numeric(10), numeric(10)))
  expect_error(mki(c(mki_ki_assessed, Inf), c(mki_ki_sale_price, 0)))
  expect_error(mki(mki_ki_assessed, c(mki_ki_sale_price, 10e5)))
  expect_error(mki(data.frame(mki_ki_assessed), mki_ki_sale_price))
  expect_error(mki(c(mki_ki_assessed, NaN), c(mki_ki_sale_price, 1)))
  expect_error(mki(c(mki_ki_assessed, "2"), c(mki_ki_sale_price, 1)))
  expect_error(mki(mki_ki_assessed, mki_ki_sale_price, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(
    mki(c(mki_ki_assessed, NA), c(mki_ki_sale_price, 10e5)),
    NA_real_
  )
  expect_equal(
    mki(c(mki_ki_assessed, NA), c(mki_ki_sale_price, 10e5), na.rm = TRUE),
    0.79,
    tolerance = 0.01
  )
})

test_that("standard met function", {
  expect_false(mki_met(mki_out))
})

test_that("all sorting variations return the same MKI (tiebreak data)", {
  mki_out_assessed <- mki(
    tiebreaks_Assessed, tiebreaks_Sale_Price
  )
  mki_out_assessed_alt_sort1 <- mki(
    tiebreaks_Assessed_alt_sort_1,
    tiebreaks_Sale_Price
  )
  mki_out_assessed_alt_sort2 <- mki(
    tiebreaks_Assessed_alt_sort_2,
    tiebreaks_Sale_Price
  )

  expect_equal(mki_out_assessed, mki_out_assessed_alt_sort1)
  expect_equal(mki_out_assessed, mki_out_assessed_alt_sort2)
})


##### TEST KI #####

# Calculate KI
ki_out <- ki(mki_ki_assessed, mki_ki_sale_price)

test_that("returns expected type", {
  expect_type(ki_out, "double")
  expect_vector(ki_out)
})

test_that("output equal to expected", {
  expect_equal(ki_out, -0.0595, tolerance = 0.003)
})

test_that("bad input data stops execution", {
  expect_error(ki(numeric(0)))
  expect_error(ki(numeric(10), numeric(10)))
  expect_error(ki(c(mki_ki_assessed, Inf), c(mki_ki_sale_price, 0)))
  expect_error(ki(mki_ki_assessed, c(mki_ki_sale_price, 10e5)))
  expect_error(ki(data.frame(mki_ki_assessed), mki_ki_sale_price))
  expect_error(ki(c(mki_ki_assessed, NaN), c(mki_ki_sale_price, 1)))
  expect_error(ki(c(mki_ki_assessed, "2"), c(mki_ki_sale_price, 1)))
  expect_error(ki(mki_ki_assessed, mki_ki_sale_price, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(
    ki(c(mki_ki_assessed, NA), c(mki_ki_sale_price, 10e5)),
    NA_real_
  )
  expect_equal(
    ki(c(mki_ki_assessed, NA), c(mki_ki_sale_price, 10e5), na.rm = TRUE),
    -0.0595,
    tolerance = 0.003
  )
})

test_that("all sorting variations return return the same ki (tiebreak data)", {
  ki_out_assessed <- ki(
    tiebreaks_Assessed,
    tiebreaks_Sale_Price
  )
  ki_out_assessed_alt_sort1 <- ki(
    tiebreaks_Assessed_alt_sort_1,
    tiebreaks_Sale_Price
  )
  ki_out_assessed_alt_sort2 <- ki(
    tiebreaks_Assessed_alt_sort_2,
    tiebreaks_Sale_Price
  )

  expect_equal(ki_out_assessed, ki_out_assessed_alt_sort1)
  expect_equal(ki_out_assessed, ki_out_assessed_alt_sort2)
})


##### TEST Median Ratio #####

test_that("standard met function", {
  expect_true(med_ratio_met(median(ratio)))
})


##### TEST VEI #####

# Calculate VEI
vei_out <- vei(assessed, sale_price)
vei_ci_out <- vei_ci(assessed, sale_price)

test_that("returns expected type", {
  expect_type(vei_out, "double")
  expect_vector(vei_out)
  expect_type(vei_ci_out, "double")
  expect_length(vei_ci_out, 2)
  expect_named(vei_ci_out, c("5%", "95%"))
})

test_that("output equal to expected", {
  expect_equal(vei_out, -2.987927, tolerance = 1e-6)
  expect_lt(vei_ci_out[[1]], vei_out)
  expect_gt(vei_ci_out[[2]], vei_out)
})

test_that("VEI matches IAAO example using R7 ranking (Table E.6.1)", {
  groups <- calc_vei(vei_assessed, vei_sale_price)$groups
  expect_equal(groups$n, c(14, 13, 13, 14))
  expect_equal(
    round(groups$median_ratio, 4),
    c(0.7280, 0.8620, 0.7537, 1.1491)
  )
  expect_equal(round(vei(vei_assessed, vei_sale_price), 2), 48.53)
  expect_false(vei_met(vei(vei_assessed, vei_sale_price)))
})

test_that("VEI CI matches IAAO example (Table E.6.2)", {
  ci <- vei_ci(vei_assessed, vei_sale_price)
  expect_equal(round(unname(ci), 2), c(29.52, 67.54))
  expect_equal(
    round(calc_vei(vei_assessed, vei_sale_price)$groups$se[c(1, 4)], 5),
    c(0.07224, 0.06957)
  )
  expect_false(
    vei_met(vei(vei_assessed, vei_sale_price), ci)
  )
})

test_that("quantile groups match IAAO R7 ranking method", {
  # Table E.5.2 (R7) for n = 54
  expect_equal(tabulate(calc_vei_groups(54, 4)), c(14, 13, 13, 14))
  # Evenly divisible samples
  expect_equal(tabulate(calc_vei_groups(100, 4)), rep(25, 4))
  expect_equal(tabulate(calc_vei_groups(1000, 10)), rep(100, 10))
})

test_that("number of quantile groups depends on sample size", {
  n_groups <- function(n) nrow(calc_vei(assessed[1:n], sale_price[1:n])$groups)
  expect_equal(n_groups(20), 2)
  expect_equal(n_groups(50), 2)
  expect_equal(n_groups(51), 4)
  expect_equal(n_groups(500), 4)
  expect_equal(n_groups(501), 10)
})

test_that("samples under 20 observations return NA with a warning", {
  expect_warning(
    expect_equal(vei(assessed[1:19], sale_price[1:19]), NA_real_),
    "at least 20 observations"
  )
  expect_warning(
    expect_equal(
      unname(vei_ci(assessed[1:19], sale_price[1:19])),
      c(NA_real_, NA_real_)
    ),
    "at least 20 observations"
  )
  expect_silent(vei(assessed[1:20], sale_price[1:20]))
})

test_that("bad input data stops execution", {
  expect_error(vei(numeric(0)))
  expect_error(vei(numeric(10), numeric(10)))
  expect_error(vei(c(assessed, Inf), c(sale_price, 0)))
  expect_error(vei(assessed, c(sale_price, 10e5)))
  expect_error(vei(data.frame(assessed), sale_price))
  expect_error(vei(c(assessed, NaN), c(sale_price, 1)))
  expect_error(vei(c(assessed, "2"), c(sale_price, 1)))
  expect_error(vei(assessed, sale_price, na.rm = "yes"))
  expect_error(vei_ci(assessed, sale_price, alpha = 1.5))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(vei(c(assessed, NA), c(sale_price, 10e5)), NA_real_)
  expect_equal(
    vei(c(assessed, NA), c(sale_price, 10e5), na.rm = TRUE),
    -2.987927,
    tolerance = 1e-6
  )
  expect_equal(vei_ci(c(assessed, NA), c(sale_price, 10e5)), NA_real_)
})

test_that("standard met function", {
  expect_true(vei_met(vei_out))
  expect_equal(
    vei_met(c(-10.5, -10, 0, 10, 10.5)),
    c(FALSE, TRUE, TRUE, TRUE, FALSE)
  )
  # IAAO Table E.7.1 outcomes
  expect_true(vei_met(5, c(-2, 12)))
  expect_true(vei_met(-22.90, c(-35.89, -9.90)))
  expect_false(vei_met(-22.90, c(-35.89, -10.5)))
  expect_false(vei_met(48.53, c(29.52, 67.54)))
  expect_error(vei_met(20, 15))
})
