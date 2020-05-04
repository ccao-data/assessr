
<!-- README.md is generated from README.Rmd. Please edit that file -->

# AssessR Package

An R package to measure the performance of property assessment using
standard statistics. Also includes a host of utility functions to make
common assessment and evaluation tasks easier and more consistent.

## Installation

You can install the released version of assessR directly from GitLab by
running the following R command after installing the `remotes` package:

``` r
remotes::install_gitlab("ccao-data-science---modeling/packages/assessr")

# Or, to install a specific version
remotes::install_gitlab("ccao-data-science---modeling/packages/assessr@0.2.0")
```

Once it is installed, you can use it just like any other package. Simply
call `library(assessr)` at the beginning of your script.

## Example Calculations

Using the included `ratios_sample` dataset, `cod()`, `prd()`, and
`prb()` can be used to measure the performance of an assessment.

``` r
library(dplyr)
library(assessr)
library(knitr)

# Load the sample dataset
data("ratios_sample")

# Calculate peformance statistics by township
ratios_sample %>%
  group_by(town) %>%
  summarize(
    cod = cod(ratio),
    cod_ci = paste(round(cod_ci(ratio, nboot = 1000), 3), collapse = ", "),
    prd = prd(assessed, sale_price),
    prd_ci = paste(round(prd_ci(assessed, sale_price), 3), collapse = ", "),
    prb = prb(assessed, sale_price),
    prb_ci = paste(round(prb_ci(assessed, sale_price), 3), collapse = ", ")
  ) %>%
  rename_all(toupper) %>%
  kable(format = "markdown", digits = 3)
```

| TOWN      |    COD | COD\_CI        |   PRD | PRD\_CI      |     PRB | PRB\_CI         |
| :-------- | -----: | :------------- | ----: | :----------- | ------: | :-------------- |
| Evanston  | 16.398 | 14.652, 18.28  | 1.033 | 1.012, 1.059 |   0.011 | \-0.012, 0.034  |
| New Trier | 19.150 | 16.992, 21.561 | 1.066 | 1.049, 1.083 | \-0.033 | \-0.063, -0.003 |

## Using Real Data

This package can easily be used with data from the [Cook County Open
Data
Portal](https://datacatalog.cookcountyil.gov/Property-Taxation/Cook-County-Assessor-s-Residential-Assessments/uqb9-r7vn)
to analyze assessment performance. To measure assessment performance,
you will need to gather both sales and assessed values. These are stored
in two separate datasets on the data portal.

### With RSocrata

[RSocrata](https://github.com/Chicago/RSocrata) is a package developed
by the City of Chicago to wrap Socrata API requests. It allows you to
easily pass a Socrata app token, which will remove the API limit on the
number of rows returned. Example usage is shown below, replacing the
login details with your own.

``` r
library(RSocrata)

# Load unlimited rows of assessment data, default is 1,000
assessments <- read.socrata(
  "https://datacatalog.cookcountyil.gov/resource/uqb9-r7vn.json",
  app_token = "YOURAPPTOKENHERE",
  email     = "user@example.com",
  password  = "fakepassword"
)
```

### With jsonlite

Socrata can also return raw JSON if you manually construct a query URL.
Follow the [API
docs](https://dev.socrata.com/foundry/datacatalog.cookcountyil.gov/uqb9-r7vn)
to alter your query. The raw JSON output can be read using the
`read_json()` function from `jsonlite`.

``` r
library(jsonlite)

# Load 100k rows of assessment data
assessments <- read_json(
  "https://datacatalog.cookcountyil.gov/resource/uqb9-r7vn.json?$limit=100000",
  simplifyVector = TRUE
)

# Load 100k rows of sales data
sales <- read_json(
  "https://datacatalog.cookcountyil.gov/resource/5pge-nu6u.json?$limit=100000",
  simplifyVector = TRUE
)
```

### Example Analysis

Using the collected assessment and sales data, we can perform a
rudimentary analysis and measure the performance of each town ship at
each stage of assessment.

``` r
library(dplyr)
library(tidyr)
library(knitr)

# Join the two datasets based on PIN, keeping only properties that have assessed
# values AND sales
combined <- inner_join(
  assessments %>% select(pin, year, town_name, first_pass, certified, bor_result),
  sales %>% select(pin, year = sale_year, sale_price),
  by = c("pin", "year")
)

# Remove sales that are not arms length, pivot to longer, then calculate 
# the ratio for each property and assessment stage
combined <- combined %>% 
  filter(sale_price >= 10000) %>%
  pivot_longer(
    first_pass:bor_result,
    names_to = "stage",
    values_to = "assessed"
  ) %>%
  mutate_at(vars(sale_price, assessed), as.numeric) %>%
  mutate(ratio = assessed / sale_price)


# For each town and stage, calculate COD, PRD, and PRB, and their respective
# confidence intervals then arrange by town name and stage of assessment
combined %>%
  group_by(town_name, stage) %>%
  summarise(
    n = n(),
    cod = cod(ratio),
    cod_ci = paste(round(cod_ci(ratio, nboot = 1000), 3), collapse = ", "),
    prd = prd(assessed, sale_price),
    prd_ci = paste(round(prd_ci(assessed, sale_price), 3), collapse = ", "),
    prb = prb(assessed, sale_price),
    prb_ci = paste(round(prb_ci(assessed, sale_price), 3), collapse = ", ")
  ) %>%
  filter(n >= 50) %>%
  mutate(stage = factor(
    stage,
    levels = c("first_pass", "certified", "bor_result"))
  ) %>%
  arrange(town_name, stage) %>%
  rename_all(toupper) %>%
  kable(format = "markdown")
```

| TOWN\_NAME  | STAGE       |   N |      COD | COD\_CI        |       PRD | PRD\_CI      |         PRB | PRB\_CI         |
| :---------- | :---------- | --: | -------: | :------------- | --------: | :----------- | ----------: | :-------------- |
| ELK GROVE   | first\_pass |  71 | 27.78232 | 18.975, 38.772 | 1.0941351 | 1.021, 1.189 | \-0.1188841 | \-0.263, 0.026  |
| ELK GROVE   | certified   |  71 | 24.46860 | 15.831, 35.096 | 1.0564095 | 0.999, 1.152 | \-0.0169422 | \-0.154, 0.12   |
| ELK GROVE   | bor\_result |  71 | 23.49757 | 15.377, 35.613 | 1.0552963 | 1.002, 1.133 | \-0.0174319 | \-0.152, 0.118  |
| EVANSTON    | first\_pass |  53 | 26.50670 | 14.517, 43.296 | 1.0327191 | 0.979, 1.095 |   0.1394950 | \-0.049, 0.328  |
| EVANSTON    | certified   |  53 | 26.38652 | 14.735, 44.334 | 1.0347494 | 0.974, 1.091 |   0.1386032 | \-0.052, 0.329  |
| EVANSTON    | bor\_result |  53 | 26.34999 | 14.208, 45.578 | 1.0426307 | 0.987, 1.115 |   0.1311480 | \-0.062, 0.325  |
| LAKE VIEW   | first\_pass | 291 | 20.05137 | 15.343, 25.757 | 1.0598831 | 1.024, 1.106 | \-0.0163193 | \-0.069, 0.037  |
| LAKE VIEW   | certified   | 291 | 18.49785 | 15.187, 22.193 | 1.0520983 | 1.022, 1.096 | \-0.0384815 | \-0.078, 0.001  |
| LAKE VIEW   | bor\_result | 291 | 18.44955 | 15.019, 22.416 | 1.0570311 | 1.024, 1.097 | \-0.0425709 | \-0.082, -0.003 |
| NEW TRIER   | first\_pass |  62 | 19.86714 | 15.668, 23.571 | 1.0348770 | 0.989, 1.077 |   0.0065982 | \-0.07, 0.083   |
| NEW TRIER   | certified   |  62 | 21.08162 | 16.627, 24.503 | 1.0400469 | 1.006, 1.071 | \-0.0007468 | \-0.08, 0.079   |
| NEW TRIER   | bor\_result |  62 | 15.68523 | 11.917, 19.839 | 1.0504330 | 1.017, 1.084 | \-0.0420508 | \-0.108, 0.024  |
| OAK PARK    | first\_pass |  53 | 28.73249 | 20.826, 38.461 | 1.0831255 | 1.015, 1.175 | \-0.0808581 | \-0.234, 0.072  |
| OAK PARK    | certified   |  53 | 28.90091 | 20.332, 39.618 | 1.0771021 | 0.994, 1.155 | \-0.0576492 | \-0.211, 0.096  |
| OAK PARK    | bor\_result |  53 | 29.96451 | 20.538, 40.447 | 1.0792164 | 1.001, 1.152 | \-0.0595960 | \-0.219, 0.1    |
| PALOS       | first\_pass |  57 | 22.94833 | 16.838, 28.738 | 0.9961811 | 0.956, 1.046 |   0.1270371 | 0.005, 0.249    |
| PALOS       | certified   |  57 | 23.20667 | 16.962, 29.418 | 0.9934735 | 0.956, 1.048 |   0.1398959 | 0.018, 0.262    |
| PALOS       | bor\_result |  57 | 21.78137 | 15.73, 28.625  | 0.9935965 | 0.952, 1.055 |   0.1260804 | 0.008, 0.244    |
| ROGERS PARK | first\_pass |  59 | 25.75073 | 16.676, 38.469 | 1.1394432 | 1.027, 1.243 | \-0.0235310 | \-0.159, 0.112  |
| ROGERS PARK | certified   |  59 | 25.79628 | 16.234, 38.633 | 1.1421130 | 1.025, 1.319 | \-0.0254053 | \-0.161, 0.11   |
| ROGERS PARK | bor\_result |  59 | 25.87248 | 16.566, 37.662 | 1.1439641 | 1.025, 1.296 | \-0.0266601 | \-0.162, 0.109  |
