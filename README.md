
<!-- README.md is generated from README.Rmd. Please edit that file -->

# AssessR Package

An R package to measure the performance of property assessment using
standard statistics. Also includes a host of utility functions to make
common assessment and evaluation tasks easier and more consistent.

## Installation

You can install the released version of assessR directly from GitLab by
running the following R command after installing the `remotes` package:

``` r
remotes::install_git("https://gitlab.com/ccao-data-science---modeling/packages/assessr")
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
    prd = prd(assessed, sale_price),
    prb = prb(assessed, sale_price),
    prb_ci = paste(round(prb_ci(assessed, sale_price), 3), collapse = ", ")
  ) %>%
  kable(format = "markdown")
```

| town      |      cod |      prd |         prb | prb\_ci         |
| :-------- | -------: | -------: | ----------: | :-------------- |
| Evanston  | 16.39764 | 1.032886 |   0.0109755 | \-0.012, 0.034  |
| New Trier | 19.14975 | 1.066341 | \-0.0328672 | \-0.063, -0.003 |
