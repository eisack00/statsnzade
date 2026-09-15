## Submission

This is the initial submission of statsnzade to CRAN.

## Test environments

* local: (fill in after running `devtools::check()`)
* R-hub / GitHub Actions: (fill in once CI is set up)

## R CMD check results

0 errors | 0 warnings | 0 notes (fill in after running `devtools::check()`)

## Notes for reviewers

* All examples that hit the live API are wrapped in `\dontrun{}` because
  they require a personal Stats NZ subscription key
  (`ade_api()` / `SNZ_PRIMARY_KEY`).
* Tests that require network access or an API key are skipped with
  `testthat::skip_if_offline()` / `skip_if()` so `R CMD check` passes
  without credentials.
