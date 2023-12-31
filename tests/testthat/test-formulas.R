context("load testing data")

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



##### TEST COD #####
context("test cod function")

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
context("test prd function")

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
context("test prb function")

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
context("test mki function")

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



##### TEST KI #####
context("test ki function")

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
