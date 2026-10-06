fixture_datasets <- tibble::tibble(
  dataset_id = c("POPES_ERP_008", "POPES_ERP_009", "POPES_ERP_010"),
  agency_id = "STATSNZ",
  version = "1.0",
  description = c(
    "Population estimate by regional council",
    "Population estimate by age group",
    "Census dwelling count by region"
  )
)

test_that("ade_search matches on id or description", {
  by_desc <- ade_search("population estimate", datasets = fixture_datasets)
  expect_equal(by_desc$dataset_id, c("POPES_ERP_008", "POPES_ERP_009"))

  by_id <- ade_search("POPES_ERP_010", datasets = fixture_datasets, field = "id")
  expect_equal(by_id$dataset_id, "POPES_ERP_010")

  none <- ade_search("nonexistent", datasets = fixture_datasets)
  expect_equal(nrow(none), 0)
})

test_that("ade_search respects field and ignore_case", {
  expect_equal(
    nrow(ade_search("POPULATION", datasets = fixture_datasets, field = "description")),
    2
  )
  expect_equal(
    nrow(ade_search("POPULATION", datasets = fixture_datasets, field = "description", ignore_case = FALSE)),
    0
  )
})

test_that("ade_dims reshapes cached codes into a list of data frames", {
  fixture_codes <- tibble::tibble(
    dataset_id = "POPES_ERP_008",
    dimension = c("AREA_POPES_ERP_008", "YEAR_POPES_ERP_008", "YEAR_POPES_ERP_008"),
    dimension_description = c("Area", "Year at 30 June", "Year at 30 June"),
    code_value = c("RC9999", "2018", "2023"),
    code_description = c("Total New Zealand by regional councils", "2018", "2023")
  )

  local_mocked_bindings(
    ade_list = function(refresh = FALSE, api_key = ade_api()) fixture_datasets
  )

  local_mocked_bindings(
    ade_fetch_dataset_structure = function(dataset, agency_id, version, api_key) fixture_codes
  )

  str <- ade_dims("POPES_ERP_008")

  expect_named(str, c("dimensions", "AREA_POPES_ERP_008", "YEAR_POPES_ERP_008"))
  expect_equal(sort(str$dimensions$dimension), c("AREA_POPES_ERP_008", "YEAR_POPES_ERP_008"))
  expect_equal(nrow(str$YEAR_POPES_ERP_008), 2)
  expect_equal(names(str$AREA_POPES_ERP_008), c("id", "label"))
})

test_that("ade_dims errors for an unknown dataset", {
  local_mocked_bindings(
    ade_list = function(refresh = FALSE, api_key = ade_api()) fixture_datasets[0, ]
  )

  expect_error(ade_dims("NOT_A_REAL_DATASET"), "Dataset \"NOT_A_REAL_DATASET\" not found")
})
