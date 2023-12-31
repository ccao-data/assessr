context("load testing data")

# Load the ratios sample dataset for testing
data("ratios_sample")

# Extract the components of the dataframe as vectors
ratio <- ratios_sample$ratio
sale_price <- ratios_sample$sale_price
assessed <- ratios_sample$assessed



##### TEST COD CI #####
context("test cod_ci function")

# Calculate PRB CI
cod_ci_out_95 <- cod_ci(ratio, nboot = 1000)
cod_ci_out_80 <- cod_ci(ratio, nboot = 1000, alpha = 0.2)

test_that("returns expected type", {
  expect_type(cod_ci_out_95, "double")
  expect_vector(cod_ci_out_95)
  expect_named(cod_ci_out_95)
})

test_that("output equal to expected", {
  expect_equivalent(cod_ci_out_95, c(16.49595, 18.84529), tolerance = 0.04)
  expect_equivalent(cod_ci_out_80, c(16.83710, 18.79953), tolerance = 0.04)
})

test_that("bad input data stops execution", {
  expect_error(cod_ci(numeric(0)))
  expect_error(cod_ci(numeric(10)))
  expect_error(cod_ci(c(ratio, Inf)))
  expect_error(cod_ci(data.frame(ratio)))
  expect_error(cod_ci(c(ratio, NaN)))
  expect_error(cod_ci(c(ratio, "2")))
  expect_error(cod_ci(ratio, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(
    cod_ci(c(ratio, NA)),
    NA_real_
  )
  expect_equivalent(
    cod_ci(c(ratio, NA), nboot = 1000, na.rm = TRUE),
    c(16.49595, 18.84529),
    tolerance = 0.04
  )
})


##### TEST PRD CI #####
context("test prb_ci function")

# Calculate PRB CI
prd_ci_out_95 <- prd_ci(assessed, sale_price, nboot = 1000)
prd_ci_out_80 <- prd_ci(assessed, sale_price, nboot = 1000, alpha = 0.2)

test_that("returns expected type", {
  expect_type(prd_ci_out_95, "double")
  expect_vector(prd_ci_out_95)
  expect_named(prd_ci_out_95)
})

test_that("output equal to expected", {
  expect_equivalent(prd_ci_out_95, c(1.034447, 1.062625), tolerance = 0.04)
  expect_equivalent(prd_ci_out_80, c(1.038444, 1.058439), tolerance = 0.04)
})

test_that("bad input data stops execution", {
  expect_error(prd_ci(numeric(0)))
  expect_error(prd_ci(numeric(10), numeric(10)))
  expect_error(prd_ci(c(assessed, Inf), c(sale_price, 0)))
  expect_error(prd_ci(assessed, c(sale_price, 10e5)))
  expect_error(prd_ci(data.frame(assessed), sale_price))
  expect_error(prd_ci(c(assessed, NaN), c(sale_price, 1)))
  expect_error(prd_ci(c(assessed, "2"), c(sale_price, 1)))
  expect_error(prd_ci(assessed, sale_price, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(
    prd_ci(c(assessed, NA), c(sale_price, 10e5)),
    NA_real_
  )
  expect_equivalent(
    prd_ci(c(assessed, NA), c(sale_price, 10e5), na.rm = TRUE),
    c(1.034447, 1.062625),
    tolerance = 0.04
  )
})



##### TEST PRB CI #####
context("test prb_ci function")

# Calculate PRB CI
prb_ci_out_95 <- prb_ci(assessed, sale_price)
prb_ci_out_80 <- prb_ci(assessed, sale_price, alpha = 0.2)

test_that("returns expected type", {
  expect_type(prb_ci_out_95, "double")
  expect_vector(prb_ci_out_95)
  expect_named(prb_ci_out_95)
})

test_that("output equal to expected", {
  expect_equivalent(prb_ci_out_95, c(-0.01404379, 0.01899536), tolerance = 0.04)
  expect_equivalent(prb_ci_out_80, c(-0.00831969, 0.01327127), tolerance = 0.04)
})

test_that("bad input data stops execution", {
  expect_error(prb_ci(numeric(0)))
  expect_error(prb_ci(numeric(10), numeric(10)))
  expect_error(prb_ci(c(assessed, Inf), c(sale_price, 0)))
  expect_error(prb_ci(assessed, c(sale_price, 10e5)))
  expect_error(prb_ci(data.frame(assessed), sale_price))
  expect_error(prb_ci(c(assessed, NaN), c(sale_price, 1)))
  expect_error(prb_ci(c(assessed, "2"), c(sale_price, 1)))
  expect_error(prb_ci(assessed, sale_price, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(
    prb_ci(c(assessed, NA), c(sale_price, 10e5)),
    NA_real_
  )
  expect_equivalent(
    prb_ci(c(assessed, NA), c(sale_price, 10e5), na.rm = TRUE),
    c(-0.01404379, 0.01899536),
    tolerance = 0.04
  )
})
