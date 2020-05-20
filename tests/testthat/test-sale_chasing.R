context("load testing data")

# Load the ratios sample dataset for testing
data("ratios_sample")

# Extract the components of the dataframe as vectors
sample_ratios <- ratios_sample$ratio
normal_ratios <- c(rnorm(1000, 1, 0.15))
chased_ratios <- c(rnorm(900, 1, 0.15), rep(1, 100))



##### TEST CHASING DETECTION #####
context("test detect_chashing function")

# Run detection
sample_out <- detect_chasing(sample_ratios)
normal_out <- detect_chasing(normal_ratios)
chased_out <- detect_chasing(chased_ratios)

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
  expect_error(detect_chasing(numeric(0)))
  expect_error(detect_chasing(c(sample_ratios, Inf)))
  expect_error(detect_chasing(data.frame(sample_ratios)))
  expect_error(detect_chasing(c(sample_ratios, NaN)))
  expect_error(detect_chasing(c(sample_ratios, "2")))
  expect_error(detect_chasing(sample_ratios, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_equal(detect_chasing(c(sample_ratios, NA)), NA)
  expect_false(detect_chasing(c(sample_ratios, NA), na.rm = TRUE))
  expect_true(detect_chasing(c(chased_ratios, NA), na.rm = TRUE))
})

test_that("warnings thrown when expected", {
  expect_warning(detect_chasing(rnorm(29)))
})
