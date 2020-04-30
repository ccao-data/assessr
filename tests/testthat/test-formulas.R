context("load data")

# Load the ratios sample dataset for testing
data("ratios_sample")

# Extract the components of the dataframe as vectors
ratios <- ratios_sample$ratio
sales <- ratios_sample$sale_price
fmvs <- ratios_sample$fmv

##### TEST cod() #####

context("test cod()")

# Calculate COD
cod_out <- cod(ratios)

test_that("returns numeric vector", {
  expect_type(cod_out, "double")
  expect_vector(cod_out)
})

test_that("output equal to expected", {
  expect_equal(cod_out, 17.81457, tolerance = 0.02)
  expect_equal(cod(c(ratios, Inf)), Inf)
  expect_equal(cod(c(numeric(10))), NaN)
})

test_that("bad input data stops execution", {
  expect_error(cod(numeric(0)))
  expect_error(cod(data.frame(ratios)))
  expect_error(cod(c(ratios, NaN)))
  expect_error(cod(c(ratios, "2")))
  expect_error(cod(ratios, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(cod(c(ratios, NA)), NA_real_)
  expect_equal(cod(c(ratios, NA), na.rm = T), 17.81457, tolerance = 0.02)
})
