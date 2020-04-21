
<!-- README.md is generated from README.Rmd. Please edit that file -->

# assessr

A package to manage, distribute, and version control commonly-used CCAO
assessment functions.

## Installation

You can install the released version of assessR directly from GitLab by
running the following R command after installing `remotes`:

``` r
remotes::install_git("https://gitlab.com/ccao-data-science---modeling/packages/assessr")
```

Once it is installed, you can use it just like any other package. Simply
call `library(assessr)` at the beginning of your script.

## Assessment Functions

This package contains functions to calculate [sales ratio study
performance
statistics](https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf).
The settings of these functions are governed by CCAO Data Science
Department SOPs. Do not change them without asking.

### Example Usage

These functions can be used to calculate the COD, PRD, or PRB of a set
of ratios.

``` r
library(assessr)
library(dplyr)
library(knitr)

data("ratios_sample")

# Calculate COD
cod_func(ratios_sample$ratios, bootstrap_n = 1000)
#> $COD
#> [1] 12.1146
#> 
#> $COD_SE
#> [1] 0.0131
#> 
#> $COD_95CI
#> [1] "(11.3536, 12.8757)"
#> 
#> $COD_N
#> [1] 881

# Calculate PRB
prb_func(
  ratios_sample$ratios,
  ratios_sample$assessed_values,
  ratios_sample$sales
)
#> $PRB
#> [1] 0.0166
#> 
#> $PRB_SE
#> [1] 0.0051
#> 
#> $PRB_95CI
#> [1] "(0.0066, 0.0265)"
#> 
#> $PRB_N
#> [1] 881
```

They can also by applied by group. For example, to get each statistic by
township.

``` r
ratios_sample %>%
  group_by(town) %>%
  summarise(
    COD = cod_func(ratios, bootstrap_n = 1000)$COD,
    PRD = prd_func(ratios, sales, bootstrap_n = 1000)$PRD,
    PRB = prb_func(ratios, sales, assessed_values)$PRB
  )
#> # A tibble: 2 x 4
#>   town        COD   PRD     PRB
#>   <chr>     <dbl> <dbl>   <dbl>
#> 1 Evanston   11.4  1.01 -0.0186
#> 2 New Trier  12.8  1.03 -0.0374
```

You can even use `dplyr` witchcraft to calculate every stat for every
group at the same time.

``` r
ratios_sample %>%
  group_by(town) %>%
  group_modify(~ {
    bind_rows(
      cod_func(.x$ratios, bootstrap_n = 1000),
      prd_func(.x$ratios, .x$sales, bootstrap_n = 1000),
      prb_func(.x$ratios, .x$sales, .x$assessed_values)
    )
  }) %>%
  summarise_each(list(~ first(.x[!is.na(.x)]))) %>%
  kable(format = "markdown")
```

| town      |     COD | COD\_SE | COD\_95CI          | COD\_N |    PRD | PRD\_SE | PRD\_95CI        | PRD\_N |      PRB | PRB\_SE | PRB\_95CI         | PRB\_N |
| :-------- | ------: | ------: | :----------------- | -----: | -----: | ------: | :--------------- | -----: | -------: | ------: | :---------------- | -----: |
| Evanston  | 11.3388 |  0.0277 | (10.2265, 12.4512) |    421 | 1.0108 |   3e-04 | (1.0004, 1.0212) |    421 | \-0.0186 |  0.0078 | (-0.034, -0.0033) |    421 |
| New Trier | 12.7475 |  0.0259 | (11.6625, 13.8325) |    458 | 1.0292 |   2e-04 | (1.0187, 1.0397) |    458 | \-0.0374 |  0.0084 | (-0.054, -0.0208) |    458 |

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
library(assessr)
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
library(assessr)
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
  pivot_longer(first_pass:bor_result, names_to = "stage", values_to = "av") %>%
  mutate_at(vars(sale_price, av), as.numeric) %>%
  mutate(ratio = av / sale_price)


# For each town and stage, calculate COD, PRD, and PRB, then arrange by stage
# and town name
combined %>%
  group_by(town_name, stage) %>%
  summarise(
    N = n(),
    COD = cod_func(ratio, bootstrap_n = 1000, suppress = TRUE)$COD,
    PRD = prd_func(ratio, sale_price, bootstrap_n = 1000, suppress = TRUE)$PRD,
    PRB = prb_func(ratio, sale_price, av, suppress = TRUE)$PRB
  ) %>%
  mutate(stage = factor(
    stage,
    levels = c("first_pass", "certified", "bor_result"))
  ) %>%
  arrange(town_name, stage) %>%
  drop_na() %>%
  kable(format = "markdown")
```

| town\_name  | stage       |   N |     COD |    PRD |      PRB |
| :---------- | :---------- | --: | ------: | -----: | -------: |
| BERWYN      | first\_pass |  41 | 22.7956 | 1.0921 | \-0.3380 |
| BERWYN      | certified   |  41 | 22.3938 | 1.0944 | \-0.3385 |
| BERWYN      | bor\_result |  41 | 22.4396 | 1.0944 | \-0.3385 |
| CICERO      | first\_pass |  31 | 21.7809 | 1.0491 | \-0.8193 |
| CICERO      | certified   |  31 | 21.6244 | 1.0494 | \-0.8213 |
| CICERO      | bor\_result |  31 | 21.7351 | 1.0504 | \-0.8366 |
| ELK GROVE   | first\_pass |  71 | 17.7603 | 1.0251 | \-0.0596 |
| ELK GROVE   | certified   |  71 | 14.7332 | 1.0004 |   0.0099 |
| ELK GROVE   | bor\_result |  71 | 14.0924 | 0.9982 |   0.0126 |
| EVANSTON    | first\_pass |  53 | 14.3180 | 1.0009 | \-0.0212 |
| EVANSTON    | certified   |  53 | 14.2568 | 1.0014 | \-0.0253 |
| EVANSTON    | bor\_result |  53 | 14.2365 | 1.0119 | \-0.0381 |
| LAKE VIEW   | first\_pass | 291 | 11.2755 | 1.0057 |   0.0024 |
| LAKE VIEW   | certified   | 291 | 11.2303 | 1.0068 |   0.0022 |
| LAKE VIEW   | bor\_result | 291 | 11.1028 | 1.0105 | \-0.0033 |
| NEW TRIER   | first\_pass |  62 | 15.1146 | 0.9929 |   0.0129 |
| NEW TRIER   | certified   |  62 | 16.3387 | 1.0049 | \-0.0062 |
| NEW TRIER   | bor\_result |  62 | 11.3103 | 1.0089 | \-0.0181 |
| OAK PARK    | first\_pass |  53 | 20.1580 | 1.0096 |   0.0216 |
| OAK PARK    | certified   |  53 | 20.3975 | 1.0036 |   0.0486 |
| OAK PARK    | bor\_result |  53 | 20.9096 | 1.0083 |   0.0348 |
| PALOS       | first\_pass |  57 | 16.9389 | 0.9966 |   0.0289 |
| PALOS       | certified   |  57 | 17.0662 | 0.9936 |   0.0489 |
| PALOS       | bor\_result |  57 | 15.7626 | 0.9920 |   0.0482 |
| ROGERS PARK | first\_pass |  59 | 16.1974 | 1.0502 | \-0.0644 |
| ROGERS PARK | certified   |  59 | 16.2160 | 1.0532 | \-0.0663 |
| ROGERS PARK | bor\_result |  59 | 16.2741 | 1.0550 | \-0.0682 |
