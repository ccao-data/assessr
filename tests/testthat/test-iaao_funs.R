context("test cod_func()")

# Set seed for testing
set.seed(1267)

# Create a random vector of ratios
ratios <- runif(1000, 0.87, 1.10)
cod_out <- cod_func(ratios)

test_that("functions return named list", {
  expect_named(cod_out)
})

test_that("output within in expected range", {
  expect_gt(cod_out$COD, 4.5)
  expect_lt(cod_out$COD, 6.0)
})

test_that("bad input data stops execution", {
  expect_condition(cod_func(c(ratios, NA)))
  expect_condition(cod_func(c(ratios, NaN)))
  expect_condition(cod_func(c(ratios, "2")))
  expect_condition(prd_func(c(ratios, NA), c(sales, 10e5)))
  expect_condition(prd_func(c(ratios, NaN), c(sales, 10e5)))
  expect_condition(prd_func(c(ratios, "2")))
})

test_that("incomplete data stops execution unless suppressed", {
  expect_condition(cod_func(runif(29)))
  expect_equal(unname(cod_func(runif(29), suppress = TRUE)), c(NA, NA, NA, NA))
})

test_that("bootstrap iter changes output", {
  expect_type(cod_func(ratios, bootstrap_n = FALSE)$COD, "double")
  expect_type(cod_func(ratios, bootstrap_n = FALSE)$COD_SE, "double")
  expect_equal(cod_func(ratios, bootstrap_n = FALSE)$COD_SE, NA_real_)
})


context("test prd_func()")

# Create a vector of sales the same length as ratios
sales <- runif(1000, 100000, 1000000)
prd_out <- prd_func(ratios, sales)

test_that("functions return named list", {
  expect_named(prd_out)
})

test_that("output within in expected range", {
  expect_gt(prd_out$PRD, 0.95)
  expect_lt(prd_out$PRD, 1.05)
})

test_that("bad input data stops execution", {
  expect_condition(prd_func(c(ratios, NA), c(sales, 10e5)))
  expect_condition(prd_func(c(ratios, NaN), c(sales, 10e5)))
  expect_condition(prd_func(c(ratios, "2"), c(sales, 10e5)))
  expect_condition(prd_func(ratios))
  expect_condition(prd_func(ratios, c(sales, NA)))
  expect_condition(prd_func(ratios, c(sales, 10000)))
})

test_that("incomplete data stops execution unless suppressed", {
  expect_condition(prd_func(runif(29), runif(29)))
  expect_equal(
    unname(prd_func(runif(29), runif(29), suppress = TRUE)),
    c(NA, NA, NA, NA)
  )
})

test_that("bootstrap iter changes output", {
  expect_type(prd_func(ratios, sales, bootstrap_n = FALSE)$PRD, "double")
  expect_type(prd_func(ratios, sales, bootstrap_n = FALSE)$PRD_SE, "double")
  expect_equal(prd_func(ratios, sales, bootstrap_n = FALSE)$PRD_SE, NA_real_)
})


context("test prb_func()")

# Create a vector of sales the same length as ratios
assessed_values <- runif(1000, 100000, 1000000)
prb_out <- prb_func(ratios, sales, assessed_values, bootstrap_n = 1000)

test_that("functions return named list", {
  expect_named(prb_out)
})

test_that("output within in expected range", {
  expect_gt(prb_out$PRB, -0.05)
  expect_lt(prb_out$PRB, 0.05)
})

test_that("bad input data stops execution", {
  expect_condition(prb_func(
    c(ratios, NA),
    c(sales, 10e5),
    c(assessed_values, 10e5))
  )
  expect_condition(prb_func(
    c(ratios, NA),
    c(sales, 10e5),
    c(assessed_values, 10e5))
  )
  expect_condition(prb_func(
    c(ratios, NA),
    c(sales, 10e5),
    c(assessed_values, 10e5))
  )
  expect_condition(prb_func(ratios))
  expect_condition(prb_func(ratios, c(sales, NA), assessed_values))
  expect_condition(prb_func(ratios, c(sales, 10000), assessed_values))
})

test_that("incomplete data stops execution unless suppressed", {
  expect_condition(prb_func(runif(29), runif(29), runif(29)))
  expect_equal(
    unname(prb_func(runif(29), runif(29), runif(29), suppress = TRUE)),
    c(NA, NA, NA, NA)
  )
})

test_that("bootstrap iter changes output", {
  expect_type(prb_func(
    ratios,
    assessed_values,
    sales,
    bootstrap_n = FALSE)$PRB,
  "double")
  expect_type(prb_func(
    ratios,
    assessed_values,
    sales,
    bootstrap_n = FALSE)$PRB_SE,
  "double")
})
