#' Get the dimensions of a dataset
#'
#' Returns the dimensions of a dataset and, for each dimension, the codes
#' Stats NZ allows for it (as defined by an `Allowed` content constraint
#' on the dataset -- see the ADE metadata guidance for details). This is
#' the information you need to build the dimension filters you pass to
#' [ade_data()].
#'
#' Unlike [ade_list()], this is fetched fresh from the API each time
#' it's needed for a new dataset (dimension metadata isn't part of the
#' on-disk cache) -- it's just kept in memory for the rest of the
#' session so repeated calls for the same dataset are free. Use
#' `refresh = TRUE` to bypass that and re-fetch.
#'
#' @param dataset A dataset id, e.g. `"POPES_ERP_008"`.
#' @param refresh Force a re-fetch from the API, bypassing the
#'   in-session cache for this dataset.
#' @param api_key API key, defaults to [ade_api()].
#'
#' @return A named list of data frames: `dimensions` (one row per
#'   dimension, with columns `dimension` and `description`), plus one
#'   further data frame per dimension (named after the dimension id) with
#'   columns `id` and `label` giving its allowed codes.
#' @export
#' @seealso [ade_data()] to download data using this structure,
#'   [ade_list()] to list datasets.
#'
#' @examples
#' \dontrun{
#' pop_dims <- ade_dims("POPES_ERP_008")
#' pop_dims$dimensions
#' pop_dims$AREA_POPES_ERP_008
#' }
ade_dims <- function(dataset, refresh = FALSE, api_key = ade_api()) {
  if (!refresh && !is.null(the$structures[[dataset]])) {
    return(the$structures[[dataset]])
  }

  datasets <- ade_list(api_key = api_key)
  row <- datasets[datasets$dataset_id == dataset, ]

  if (nrow(row) == 0) {
    cli::cli_abort(c(
      "Dataset {.val {dataset}} not found.",
      "i" = "Try {.fun ade_search} to find the correct id, or {.code ade_list(refresh = TRUE)} to refresh the cache."
    ))
  }

  codes <- tryCatch(
    ade_fetch_dataset_structure(dataset, row$agency_id[1], row$version[1], api_key),
    error = function(e) {
      cli::cli_abort(c(
        "Failed to fetch data structure for {.val {dataset}}.",
        "x" = conditionMessage(e)
      ))
    }
  )

  if (nrow(codes) == 0) {
    cli::cli_abort("No data structure found for dataset {.val {dataset}}.")
  }

  dimensions <- unique(codes[, c("dimension", "dimension_description")])
  names(dimensions) <- c("dimension", "description")
  rownames(dimensions) <- NULL

  codelists <- split(codes, codes$dimension)
  codelists <- lapply(codelists, function(d) {
    out <- unique(d[, c("code_value", "code_description")])
    names(out) <- c("id", "label")
    rownames(out) <- NULL
    out
  })

  out <- c(list(dimensions = tibble::as_tibble(dimensions)), codelists)
  the$structures[[dataset]] <- out
  out
}
