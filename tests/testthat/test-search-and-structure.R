fixture_datasets <- tibble::tibble(
  dataset_id = c("CPI_ALC_001", "CPI_FPI_001", "CPI_FPI_002"),
  agency_id = "STATSNZ.ECIN",
  version = "1",
  description = c(
    "Consumer Price Index: Alcohol and Tobacco Index for New Zealand",
    "Consumer Price Index: Food Price Index for New Zealand",
    "Consumer Price Index: Food Price Index for Regions"
  )
)

test_that("ade_search matches on id or description", {
  by_desc <- ade_search("food price", datasets = fixture_datasets)
  expect_equal(by_desc$dataset_id, c("CPI_FPI_001", "CPI_FPI_002"))

  by_id <- ade_search("CPI_ALC", datasets = fixture_datasets, field = "id")
  expect_equal(by_id$dataset_id, "CPI_ALC_001")

  none <- ade_search("nonexistent", datasets = fixture_datasets)
  expect_equal(nrow(none), 0)
})

test_that("ade_search respects field and ignore_case", {
  expect_equal(
    nrow(ade_search("FOOD", datasets = fixture_datasets, field = "description")),
    2
  )
  expect_equal(
    nrow(ade_search("FOOD", datasets = fixture_datasets, field = "description", ignore_case = FALSE)),
    0
  )
})

test_that("ade_dims reshapes cached codes into a list of data frames", {
  fixture_codes <- tibble::tibble(
    dataset_id = "CPI_ALC_001",
    dimension = c("FREQ", "CPI_MEASURE", "CPI_MEASURE"),
    dimension_description = c("Frequency", "Measure", "Measure"),
    code_value = c("M", "B", "AC"),
    code_description = c("Monthly", "Index number", "Percentage change")
  )

  local_mocked_bindings(
    ade_list = function(refresh = FALSE, api_key = ade_api()) fixture_datasets
  )

  local_mocked_bindings(
    ade_fetch_dataset_structure = function(dataset, agency_id, version, api_key) fixture_codes
  )

  str <- ade_dims("CPI_ALC_001")

  expect_named(str, c("dimensions", "CPI_MEASURE", "FREQ"))
  expect_equal(sort(str$dimensions$dimension), c("CPI_MEASURE", "FREQ"))
  expect_equal(nrow(str$CPI_MEASURE), 2)
  expect_equal(names(str$FREQ), c("id", "label"))
})

test_that("ade_dims errors for an unknown dataset", {
  local_mocked_bindings(
    ade_list = function(refresh = FALSE, api_key = ade_api()) fixture_datasets[0, ]
  )

  expect_error(ade_dims("NOT_A_REAL_DATASET"), "Dataset \"NOT_A_REAL_DATASET\" not found")
})
