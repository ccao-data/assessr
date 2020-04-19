
<!-- README.md is generated from README.Rmd. Please edit that file -->

# assessR

A package to manage, distribute, and version control commonly-used CCAO
assessment functions.

## Installation

You can install the released version of assessR directly from GitLab,
but you’ll first need to generate an authorization token by following
[these
steps](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html#creating-a-personal-access-token).

Then run the following R command, replacing the `auth_token` argument
with your own token:

``` r
remotes::install_gitlab(
  repo = "ccao-data-science---modeling/packages/assessR",
  auth_token = "<your-personal-access-token>"
)
```

Once it is installed, you can use it just like any other package. Simply
call `library(assessR)` at the beginning of your script.

## IAAO Functions

This package contains functions to calculate [IAAO sales ratio study
performance
statistics](https://www.iaao.org/media/standards/Standard_on_Ratio_Studies.pdf).
The settings of these functions are governed by CCAO Data Science
Department SOPs. Do not change them without asking.

### Example Usage

These functions can be used to calculate the COD, PRD, or PRB of a set
of ratios. They can also be applied by group.

``` r
library(assessR)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

data("ratios_sample")

## For a single vector of ratios
# Calculate COD
cod_func(ratios_sample$ratios, bootstrap_n = 1000)
#> $COD
#> [1] 12.1221
#> 
#> $COD_SE
#> [1] 0.013
#> 
#> $COD_95CI
#> [1] "(11.363, 12.8812)"
#> 
#> $COD_N
#> [1] 881

# Calculate PRB
prb_func(
  ratios_sample$ratios,
  ratios_sample$assessed_values,
  ratios_sample$sales,
  bootstrap_n = 1000
)
#> $PRB
#> [1] -0.0165
#> 
#> $PRB_SE
#> [1] 0.0051
#> 
#> $PRB_95CI
#> [1] "(-0.0265, -0.0066)"
#> 
#> $PRB_N
#> [1] 881


## Calculate each statistic by group
ratios_sample %>%
  group_by(town) %>%
  summarise(
    COD = cod_func(ratios, bootstrap_n = 1000)$COD,
    PRD = prd_func(ratios, sales, bootstrap_n = 1000)$PRD,
    PRB = prb_func(ratios, sales, assessed_values, bootstrap_n = 1000)$PRB
  )
#> # A tibble: 2 x 4
#>   town        COD   PRD    PRB
#>   <chr>     <dbl> <dbl>  <dbl>
#> 1 Evanston   11.3  1.01 0.0193
#> 2 New Trier  12.7  1.03 0.0101

## Some witchcraft to calculate every stat at once for each group
ratios_sample %>%
  group_by(town) %>%
  group_modify(~ {
    bind_rows(
      cod_func(.x$ratios, bootstrap_n = 1000),
      prd_func(.x$ratios, .x$sales, bootstrap_n = 1000),
      prb_func(.x$ratios, .x$sales, .x$assessed_values, bootstrap_n = 1000)
    )
  }) %>%
  summarise_each(list(~ first(.x[!is.na(.x)]))) 
#> # A tibble: 2 x 13
#>   town    COD COD_SE COD_95CI COD_N   PRD  PRD_SE PRD_95CI PRD_N    PRB PRB_SE
#>   <chr> <dbl>  <dbl> <chr>    <int> <dbl>   <dbl> <chr>    <int>  <dbl>  <dbl>
#> 1 Evan~  11.3 0.0261 (10.295~   421  1.01 3.00e-4 (1.0003~   421 0.0196 0.0077
#> 2 New ~  12.8 0.0246 (11.718~   458  1.03 3.00e-4 (1.0189~   458 0.0108 0.0088
#> # ... with 2 more variables: PRB_95CI <chr>, PRB_N <dbl>
```
