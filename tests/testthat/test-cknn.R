context("load testing data")

library(dplyr)
library(testthat)
library(assessr)
set.seed(1000)

sales_prepped <- assessr:::sales_prepped
properties_prepped <- assessr:::properties_prepped

##### TEST CKNN #####
context("test cknn function")

data <- sales_prepped %>% select(-pin, -sale_price, -lon, -lat)
data_lpd <- data %>% mutate(across(air:gar1_size, forcats::fct_lump_lowfreq))
lon <- sales_prepped %>% pull(lon)
lat <- sales_prepped %>% pull(lat)

w <- c("bsmt_fin" = 10, "bldg_sf" = 30)
clust_out <- cknn(data = data_lpd, lon = lon, lat = lat, m = 8)

test_that("output has expected attributes", {
  expect_s3_class(clust_out, "cknn")
  expect_s3_class(clust_out$kproto, "kproto")
  expect_length(clust_out, 9)
  expect_length(clust_out$knn, 1978)
  expect_length(unique(clust_out$kproto$cluster), 8)
})

test_that("warnings thrown when expected", {
  # Warn when factors have rare levels
  expect_warning(cknn(data = data, lon = lon, lat = lat, var_weights = 1))
  expect_warning(cknn(data = data, lon = lon, lat = lat, var_weights = w))
})

test_that("bad input data stops execution", {
  # Warn when missing vals present
  expect_error(
    cknn(
      data = data_lpd %>%
        mutate(bsmt = ifelse(row_number() %in% sample(bsmt, 10), NA, bsmt)),
      lon = lon, lat = lat, var_weights = rep(1, 10)
    )
  )

  # Stop when cols are not numeric or factor
  expect_error(cknn(data_lpd %>% mutate(bsmt = as.character(bsmt)), lon, lat))

  # Stop when var weights input has names not in the input data
  w <- c("bsmt" = 10, "sale_price" = 30)
  expect_error(cknn(data_lpd, lon, lat, var_weights = w))
})


##### TEST CKNN.PREDICT #####
context("test cknn_predict function")

pred_data <- properties_prepped %>% select(-price, -lon, -lat)
pred_lon <- properties_prepped %>% pull(lon)
pred_lat <- properties_prepped %>% pull(lat)

comparables <- predict(clust_out, pred_data, pred_lon, pred_lat, 11)

test_that("output has expected attributes", {
  expect_type(comparables, "list")
  expect_length(comparables, 2)
  expect_length(comparables$knn, 426)
  expect_length(comparables$cluster, 426)
})

test_that("bad input data stops execution", {
  expect_error(
    predict(clust_out, pred_data %>% rename(sqft = bldg_sf), pred_lon, pred_lat)
  )
  expect_error(
    predict(
      clust_out,
      pred_data %>% mutate(bldg_sf = as.factor(bldg_sf)),
      pred_lon,
      pred_lat
    )
  )
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
