library(dplyr)
library(ccao)
library(sf)

# Load max 100k rows of sales data for Evanston
sales_prepped <- jsonlite::read_json(
  "https://datacatalog.cookcountyil.gov/resource/5pge-nu6u.json?$limit=10000&town_code=17", # nolint
  simplifyVector = TRUE
) %>%
  filter(
    sale_year >= 2016,
    sale_price >= 10000,
    !class %in% c(211, 212, 299),
    as.numeric(rooms) <= 14,
    !is.na(centroid_x)
  ) %>%
  # Keep only the variables used for clustering (except sale price, which is
  # removed later)
  select(
    pin, sale_price, bldg_sf, age, rooms, beds,
    air, bsmt, bsmt_fin, ext_wall, heat, gar1_size,
    lon = centroid_x, lat = centroid_y
  ) %>%
  # Convert categorical variables to factor and numbers to numeric
  mutate(
    across(air:gar1_size, as.factor),
    across(c(sale_price:beds, lon, lat), as.numeric),
  ) %>%
  ccao::vars_recode(type = "code") %>%
  # Convert lat/lon to planar projection. In the case of Illinois, 3435 is ideal
  # This code converts to the new coordinate system, but immediately removes the
  # resulting geometry column (only the coordinates are needed)
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_transform(3435) %>%
  mutate(lon = st_coordinates(.)[, 1], lat = st_coordinates(.)[, 2]) %>%
  st_set_geometry(NULL) %>%
  # Filter rare factor levels
  filter(!bsmt_fin == "2", !gar1_size %in% c("6", "7"), !is.na(heat))

# Load 100k rows of characteristic data for Evanston
properties_prepped <- jsonlite::read_json(
  "https://datacatalog.cookcountyil.gov/resource/bcnq-qi2z.json?$limit=10000&town_code=17", # nolint
  simplifyVector = TRUE
) %>%
  filter(!pin %in% sales_prepped$pin) %>%
  filter(
    !class %in% c(211, 212, 299),
    rooms <= 14,
    !is.na(centroid_x)
  ) %>%
  mutate(price = as.numeric(pri_est_bldg) + as.numeric(pri_est_land)) %>%
  # Keep exactly the same columns as the sales_prepped data frame
  select(
    price, bldg_sf, age, rooms, beds,
    air, bsmt, bsmt_fin, ext_wall, heat, gar1_size,
    lon = centroid_x, lat = centroid_y
  ) %>%
  # Convert to numeric and factor types
  mutate(
    across(air:gar1_size, as.factor),
    across(c(bldg_sf:beds, lon, lat), as.numeric)
  ) %>%
  ccao::vars_recode(type = "code") %>%
  # Reproject coordinates into planar meters
  st_as_sf(coords = c("lon", "lat"), crs = 4326) %>%
  st_transform(3435) %>%
  mutate(lon = st_coordinates(.)[, 1], lat = st_coordinates(.)[, 2]) %>%
  st_set_geometry(NULL) %>%
  # Filter rare factor levels
  filter(!bsmt_fin == "2", !gar1_size %in% c("6", "7"), !is.na(heat))

usethis::use_data(
  sales_prepped,
  properties_prepped,
  internal = TRUE,
  overwrite = TRUE,
  compress = "bzip2",
  version = 2
)
