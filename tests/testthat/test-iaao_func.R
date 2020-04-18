set.seed(1267)

ratios <- runif(1000, 0.87, 1.10)
cod_out <- cod_func(ratios)

context("test-iaao_func.R")

test_that("returns named list", {
  expect_named(cod_out)
})

test_that("COD in expected range", {
  expect_gt(cod_out$COD, 4.5)
  expect_lt(cod_out$COD, 6.0)
})

test_that("bad data stops execution", {
  expect_condition(cod_func(c(ratios, NA)))
  expect_condition(cod_func(c(ratios, NaN)))
  expect_condition(cod_func(c(ratios, "2")))
})

test_that("incomplete data stops execution unless suppressed", {
  expect_condition(cod_func(runif(29)))
  expect_equal(unname(cod_func(runif(29), suppress = TRUE)), c(NA, NA, NA, NA))
})

test_that("bootstrap iter changes work", {
  expect_type(cod_func(ratios, bootstrap_n = FALSE)$COD, "double")
  expect_type(cod_func(ratios, bootstrap_n = FALSE)$COD_SE, "double")
  expect_equal(cod_func(ratios, bootstrap_n = FALSE)$COD_SE, NA_real_)
})

if (requireNamespace("lintr", quietly = TRUE)) {
  context("lintr coverage")
  test_that("no lintr errors", {
    lintr::expect_lint_free()
  })
}
