test_that("ade_api round-trip", {
  withr::local_envvar(SNZ_PRIMARY_KEY = NA)
  withr::local_options(statsnzade.api_key = NULL)

  ade_api("test-key-123")
  expect_equal(ade_api(), "test-key-123")
})

test_that("ade_api falls back to the environment variable", {
  withr::local_options(statsnzade.api_key = NULL)
  withr::local_envvar(SNZ_PRIMARY_KEY = "env-key-456")

  expect_equal(ade_api(), "env-key-456")
})

test_that("ade_api errors with no key set", {
  withr::local_envvar(SNZ_PRIMARY_KEY = NA)
  withr::local_options(statsnzade.api_key = NULL)

  expect_error(ade_api(), "No Stats NZ API key found")
})

test_that("ade_api validates its input", {
  expect_error(ade_api(123))
  expect_error(ade_api(character(0)))
  expect_error(ade_api(""))
})
