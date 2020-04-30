context("load data")

# Load the ratios sample dataset for testing
data("ratios_sample")

# Extract the components of the dataframe as vectors
ratios <- ratios_sample$ratio
sale_prices <- ratios_sample$sale_price
assessed_vals <- ratios_sample$assessed

##### TEST cod() #####

context("test cod function")

# Calculate COD
cod_out <- cod(ratios)

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
  expect_error(cod(data.frame(ratios)))
  expect_error(cod(c(ratios, NaN)))
  expect_error(cod(c(ratios, "2")))
  expect_error(cod(ratios, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(cod(c(ratios, NA)), NA_real_)
  expect_equal(cod(c(ratios, NA), na.rm = T), 17.81457, tolerance = 0.02)
})


##### TEST prd() #####

context("test prd function")

# Calculate PRD
prd_out <- prd(assessed_vals, sale_prices)

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
  expect_error(prd(assessed_vals, c(sale_prices, 10e5)))
  expect_error(prd(data.frame(assessed_vals), sale_prices))
  expect_error(prd(c(assessed_vals, NaN), c(sale_prices, 1)))
  expect_error(prd(c(assessed_vals, "2"), c(sale_prices, 1)))
  expect_error(prd(assessed_vals, sale_prices, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(
    prd(c(assessed_vals, NA), c(sale_prices, 10e5)),
    NA_real_
  )
  expect_equal(
    prd(c(assessed_vals, NA), c(sale_prices, 10e5), na.rm = TRUE),
    1.048419,
    tolerance = 0.02
  )
})


##### TEST prb() #####

context("test prb function")

# Calculate PRB
prb_out <- prb(assessed_vals, sale_prices)

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
  expect_error(prb(assessed_vals, c(sale_prices, 10e5)))
  expect_error(prb(data.frame(assessed_vals), sale_prices))
  expect_error(prb(c(assessed_vals, NaN), c(sale_prices, 1)))
  expect_error(prb(c(assessed_vals, "2"), c(sale_prices, 1)))
  expect_error(prb(assessed_vals, sale_prices, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(
    prb(c(assessed_vals, NA), c(sale_prices, 10e5)),
    NA_real_
  )
  expect_equal(
    prb(c(assessed_vals, NA), c(sale_prices, 10e5), na.rm = TRUE),
    0.0024757,
    tolerance = 0.02
  )
})
