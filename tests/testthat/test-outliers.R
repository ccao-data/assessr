context("load testing data")

# Create test vectors of data with certain distributions
set.seed(13378)

# Normal distribution, no outliers
test_dist1 <- rnorm(100)

# Normal distribution, some outliers
test_dist2 <- c(rnorm(100), 3, 4, 5, 6, 7)

# Non-normal, super narrow distribution
test_dist3 <- c(runif(20), rep(1, 50), 5, 6, 7)

# Create outputs for all distributions
dist1_iqr_out <- is_outlier(test_dist1, method = "iqr")
dist1_qnt_out <- is_outlier(test_dist1, method = "quantile")
dist2_iqr_out <- is_outlier(test_dist2, method = "iqr")
dist2_qnt_out <- is_outlier(test_dist2, method = "quantile")



##### TEST OUTLIER #####
context("test is_outlier function")

test_that("returns expected type", {
  expect_type(dist1_iqr_out, "logical")
  expect_vector(dist1_iqr_out)

  expect_type(dist1_qnt_out, "logical")
  expect_vector(dist1_qnt_out)
})

test_that("output equal to expected", {
  expect_equal(sum(dist1_iqr_out), 0) # 0 outliers
  expect_equal(sum(dist1_qnt_out), 10) # 4 outliers
  expect_equal(sum(dist2_iqr_out), 2)
  expect_equal(sum(dist2_qnt_out), 12)
})

test_that("bad input data stops execution", {
  expect_error(is_outlier(numeric(0)))
  expect_error(is_outlier(data.frame(ratio)))
  expect_error(is_outlier(c(dist1_iqr_out, Inf)))
  expect_error(is_outlier(c(dist1_iqr_out, NaN)))
  expect_error(is_outlier(c(dist1_iqr_out, "2")))
  expect_error(is_outlier(dist1_iqr_out, na.rm = "yes"))
})

test_that("incomplete data returns NAs unless removed", {
  expect_error(is_outlier(c(dist1_iqr_out, NA)))
  expect_equal(
    is_outlier(c(test_dist1, NA)),
    c(rep(FALSE, 100), NA)
  )
  expect_equal(
    is_outlier(c(test_dist1, NA), method = "quantile"),
    c(dist1_qnt_out, NA)
  )
})

test_that("warnings thrown when expected", {
  expect_warning(is_outlier(test_dist3, method = "iqr"))
  expect_warning(is_outlier(rnorm(20), method = "quantile"))
})
