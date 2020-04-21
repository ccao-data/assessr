context("test pin_clean()")

##### TEST pin_clean() #####

# Create vector of sample pins
pins <- c("04-34-106-008-0000", " 14172 27008 0000", "433334-- 4232")

test_that("clean output is correct", {
  expect_equal(
    pin_clean(pins),
    c("04341060080000", "14172270080000", "4333344232")
  )
})

test_that("incorrect inputs throw warning", {
  expect_warning(pin_clean(c(pins, "0004423a3232")))
  expect_warning(pin_clean(list(pins, 44323888322)))
  expect_warning(pin_clean(c(44323888322, 03223232123)))
  expect_condition(pin_clean(data.frame(pins)))
})


##### TEST pin_format_pretty() #####

context("test pin_format_pretty()")

# Create a vector of clean PINs with no dashes
pins <- c("04341060080001", "01222040030030", "1417227008")

test_that("pretty printed output is correct", {
  expect_equal(
    pin_format_pretty(pins, full_length = TRUE),
    c("04-34-106-008-0001", "01-22-204-003-0030", "14-17-227-008")
  )
  expect_equal(
    pin_format_pretty(pins),
    c("04-34-106-008", "01-22-204-003", "14-17-227-008")
  )
})

test_that("pins must be correct length", {
  expect_condition(pin_format_pretty(c(pins, "14172270080")))
  expect_condition(pin_format_pretty(c(pins, "012220400300000")))
})

test_that("incorrect inputs stops process", {
  expect_condition(pin_format_pretty(data.frame(pins)))
  expect_condition(pin_format_pretty(as.numeric(pins)))
  expect_condition(pin_format_pretty(list(pins, 012220400300000)))
})
