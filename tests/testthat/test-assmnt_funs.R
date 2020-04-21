context("load data")

# Load the ratios sample dataset for testing
data("ratios_sample")

# Extract the components of the dataframe as vectors
ratios <- ratios_sample$ratios
sales <- ratios_sample$sales
assessed_values <- ratios_sample$assessed_values


##### TEST cod_func() #####

context("test cod_func()")

# Calculate COD
cod_out <- cod_func(ratios, bootstrap_n = 1000)

test_that("functions return named list", {
  expect_type(cod_out, "list")
  expect_named(cod_out)
})

test_that("output within in expected range", {
  expect_gt(cod_out$COD, 11)
  expect_lt(cod_out$COD, 13)
})

test_that("bad input data stops execution", {
  expect_condition(cod_func(data.frame(ratios)))
  expect_condition(cod_func(c(ratios, NA)))
  expect_condition(cod_func(c(ratios, NaN)))
  expect_condition(cod_func(c(ratios, "2")))
})

test_that("incomplete data stops execution unless suppressed", {
  expect_condition(cod_func(runif(29)))
  expect_equal(
    unname(cod_func(runif(29), suppress = TRUE)),
    list(NA, NA, NA, NA)
  )
})

test_that("bootstrap iter changes output", {
  expect_type(cod_func(ratios, bootstrap_n = FALSE)$COD, "double")
  expect_type(cod_func(ratios, bootstrap_n = FALSE)$COD_SE, "double")
  expect_equal(cod_func(ratios, bootstrap_n = FALSE)$COD_SE, NA_real_)
})


##### TEST prd_func() #####

context("test prd_func()")

# Calculate PRD from sample
prd_out <- prd_func(ratios, sales, bootstrap_n = 1000)

test_that("functions return named list", {
  expect_type(prd_out, "list")
  expect_named(prd_out)
})

test_that("output within expected range", {
  expect_gt(prd_out$PRD, 0.98)
  expect_lt(prd_out$PRD, 1.03)
})

test_that("bad input data stops execution", {
  expect_condition(prd_func(data.frame(ratios), sales))
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
    list(NA, NA, NA, NA)
  )
})

test_that("bootstrap iter changes output", {
  expect_type(prd_func(ratios, sales, bootstrap_n = FALSE)$PRD, "double")
  expect_type(prd_func(ratios, sales, bootstrap_n = FALSE)$PRD_SE, "double")
  expect_equal(prd_func(ratios, sales, bootstrap_n = FALSE)$PRD_SE, NA_real_)
})


##### TEST prb_func() #####

context("test prb_func()")

# Create a vector of sales the same length as ratios
prb_out <- prb_func(ratios, sales, assessed_values)

test_that("functions return named list", {
  expect_type(prb_out, "list")
  expect_named(prb_out)
})

test_that("output within expected range", {
  expect_gt(prb_out$PRB, -0.03)
  expect_lt(prb_out$PRB, 0.03)
})

test_that("bad input data stops execution", {
  expect_condition(prd_func(data.frame(ratios), sales, assessed_values))
  expect_condition(prb_func(
    c(ratios, NA),
    c(sales, 10e5),
    c(assessed_values, 10e5)
  ))
  expect_condition(prb_func(
    c(ratios, NA),
    c(sales, 10e5),
    c(assessed_values, 10e5)
  ))
  expect_condition(prb_func(
    c(ratios, NA),
    c(sales, 10e5),
    c(assessed_values, 10e5)
  ))
  expect_condition(prb_func(ratios))
  expect_condition(prb_func(ratios, c(sales, NA), assessed_values))
  expect_condition(prb_func(ratios, c(sales, 10000), assessed_values))
})

test_that("incomplete data stops execution unless suppressed", {
  expect_condition(prb_func(runif(29), runif(29), runif(29)))
  expect_equal(
    unname(prb_func(runif(29), runif(29), runif(29), suppress = TRUE)),
    list(NA, NA, NA, NA)
  )
})
