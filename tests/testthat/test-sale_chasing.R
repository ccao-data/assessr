context("load testing data")

# Load the ratios sample dataset for testing
data("ratios_sample")

# Extract the components of the dataframe as vectors
sample_ratios <- ratios_sample$estimate / ratios_sample$sale_price
normal_ratios <- c(rnorm(1000, 1, 0.15))
chased_ratios <- c(rnorm(900, 1, 0.15), rep(1, 100))



##### TEST CHASING DETECTION #####
context("test is_sales_chased function")

# Run detection
sample_out <- is_sales_chased(sample_ratios)
normal_out <- is_sales_chased(normal_ratios)
chased_out <- is_sales_chased(chased_ratios)

test_that("returns logical value", {
  expect_type(sample_out, "logical")
  expect_vector(sample_out)
  expect_length(sample_out, 1)
})

test_that("output equal to expected", {
  expect_false(sample_out)
  expect_false(normal_out)
  expect_true(chased_out)
})

test_that("bad input data stops execution", {
  expect_error(is_sales_chased(numeric(0)))
  expect_error(is_sales_chased(c(sample_ratios, Inf)))
  expect_error(is_sales_chased(data.frame(sample_ratios)))
  expect_error(is_sales_chased(c(sample_ratios, NaN)))
  expect_error(is_sales_chased(c(sample_ratios, "2")))
  expect_error(is_sales_chased(sample_ratios, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(is_sales_chased(c(sample_ratios, NA)), NA)
  expect_false(is_sales_chased(c(sample_ratios, NA), na.rm = TRUE))
  expect_true(is_sales_chased(c(chased_ratios, NA), na.rm = TRUE))
})

test_that("warnings thrown when expected", {
  expect_warning(is_sales_chased(rnorm(29)))
})
