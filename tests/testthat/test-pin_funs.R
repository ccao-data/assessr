context("test pin_clean()")

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
