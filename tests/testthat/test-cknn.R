context("load testing data")

library(dplyr)
library(testthat)
library(assessr)
set.seed(1000)

sales_prepped <- assessr:::sales_prepped
properties_prepped <- assessr:::properties_prepped

##### TEST CKNN #####
context("test cknn function")

data <- sales_prepped %>%
  select(-pin, -sale_price, -lon, -lat) %>%
  mutate(across(where(is.factor), forcats::fct_explicit_na))
lon <- sales_prepped %>% pull(lon)
lat <- sales_prepped %>% pull(lat)

w <- c("bsmt_fin" = 10, "bldg_sf" = 30)
clust_out <- cknn(data = data, lon = lon, lat = lat, m = 8)

test_that("output has expected attributes", {
  expect_s3_class(clust_out, "cknn")
  expect_s3_class(clust_out$kproto, "kproto")
  expect_length(clust_out, 9)
  expect_length(clust_out$knn, 1958)
  expect_length(unique(clust_out$kproto$cluster), 8)
})

test_that("warnings thrown when expected", {
  # Warn when factors have rare levels
  data_w_rare <- bind_rows(
    data, data %>% slice(10) %>% mutate(bsmt_fin = factor("4"))
  )
  expect_warning(
    cknn(
      data = data_w_rare,
      lon = c(lon, 1e6),
      lat = c(lat, 1.9e6),
      var_weights = 1
    )
  )
  expect_warning(
    cknn(
      data = data_w_rare,
      lon = c(lon, 1e6),
      lat = c(lat, 1.9e6),
      var_weights = w
    )
  )
})

test_that("bad input data stops execution", {
  # Warn when missing vals present
  expect_error(
    cknn(
      data = data %>%
        mutate(bsmt = ifelse(row_number() %in% sample(bsmt, 10), NA, bsmt)),
      lon = lon, lat = lat, var_weights = rep(1, 10)
    )
  )

  # Stop when cols are not numeric or factor
  expect_error(cknn(data %>% mutate(bsmt = as.character(bsmt)), lon, lat))

  # Stop when var weights input has names not in the input data
  w <- c("bsmt" = 10, "sale_price" = 30)
  expect_error(cknn(data, lon, lat, var_weights = w))
})

test_that("results are consistent when seed set", {
  expect_known_hash(clust_out, "c3e9694d38")
})


##### TEST CKNN.PREDICT #####
context("test cknn_predict function")

pred_data <- properties_prepped %>%
  select(-price, -lon, -lat) %>%
  mutate(across(where(is.factor), forcats::fct_explicit_na))
pred_lon <- properties_prepped %>% pull(lon)
pred_lat <- properties_prepped %>% pull(lat)

comparables <- predict(clust_out, pred_data, pred_lon, pred_lat, 11)

test_that("output has expected attributes", {
  expect_type(comparables, "list")
  expect_length(comparables, 5)
  expect_length(comparables$knn, 412)
  expect_length(comparables$cluster, 412)
})

test_that("bad input data stops execution", {
  # Error on new data containing different cols than original
  expect_error(
    predict(clust_out, pred_data %>% rename(sqft = bldg_sf), pred_lon, pred_lat)
  )
  # Error and invalid params
  expect_error(predict(clust_out, pred_data, pred_lon, pred_lat, k = -1))
  expect_error(predict(clust_out, pred_data, pred_lon, pred_lat, l = 2))
  expect_error(predict(clust_out, pred_data, pred_lon, pred_lat, l = -0.5))
  # Error on coltype of new data not matching original
  expect_error(
    predict(
      clust_out,
      pred_data %>% mutate(bldg_sf = as.factor(bldg_sf)),
      pred_lon,
      pred_lat
    )
  )
  # Error on NAs in input data
  expect_error(
    predict(
      clust_out,
      pred_data %>%
        mutate(bsmt = ifelse(row_number() %in% sample(bsmt, 10), NA, bsmt)),
      pred_lon,
      pred_lat
    )
  )
})

test_that("results are consistent when seed set", {
  expect_known_hash(comparables, "022aff029b")
})
