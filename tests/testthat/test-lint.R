context("lintr coverage")

test_that("no lintr errors", {
  lintr::expect_lint_free(
    linters = lintr::linters_with_defaults(
      object_name_linter = NULL
    ),
    path = "../.."
  )
})
