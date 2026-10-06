test_that("ade_build_key returns 'all' for NULL filter", {
  expect_equal(ade_build_key("ANY_DATASET", filter = NULL), "all")
})

test_that("ade_build_key builds a named-list key without hitting the network", {
  local_mocked_bindings(
    ade_dims = function(dataset, refresh = FALSE) {
      list(dimensions = tibble::tibble(dimension = c("FREQ", "MEASURE", "CATEGORY")))
    }
  )

  expect_equal(
    ade_build_key("TEST_DATASET", filter = list(FREQ = "M")),
    "M.."
  )
  expect_equal(
    ade_build_key("TEST_DATASET", filter = list(FREQ = "M", MEASURE = c("B", "AC"))),
    "M.B+AC."
  )
})

test_that("ade_build_key builds a positional key without hitting the network", {
  local_mocked_bindings(
    ade_dims = function(dataset, refresh = FALSE) {
      list(dimensions = tibble::tibble(dimension = c("FREQ", "MEASURE", "CATEGORY")))
    }
  )

  expect_equal(
    ade_build_key("TEST_DATASET", filter = list("M", "", "")),
    "M.."
  )
})

test_that("ade_build_key errors on unknown named dimensions", {
  local_mocked_bindings(
    ade_dims = function(dataset, refresh = FALSE) {
      list(dimensions = tibble::tibble(dimension = c("FREQ")))
    }
  )

  expect_error(
    ade_build_key("TEST_DATASET", filter = list(NOT_A_DIM = "X")),
    "Unknown dimension"
  )
})

test_that("ade_build_key errors on positional filter of wrong length", {
  local_mocked_bindings(
    ade_dims = function(dataset, refresh = FALSE) {
      list(dimensions = tibble::tibble(dimension = c("FREQ", "MEASURE")))
    }
  )

  expect_error(
    ade_build_key("TEST_DATASET", filter = list("M")),
    "dimension value"
  )
})

test_that("ade_cache_path returns a path under a real, existing directory", {
  path <- ade_cache_path()
  expect_true(dir.exists(dirname(path)))
  expect_match(path, "statsnzade\\.sqlite$")
})

test_that("ade_cache_info reports a missing cache without building one", {
  withr::local_options(statsnzade.api_key = "unused")
  # Point the cache at a throwaway location so this test never touches
  # a real cache file left over from other tests/sessions.
  fake_dir <- withr::local_tempdir()
  local_mocked_bindings(
    ade_cache_path = function() file.path(fake_dir, "statsnzade.sqlite")
  )

  info <- ade_cache_info()
  expect_false(info$exists)
  expect_true(is.na(info$built_at))
})
