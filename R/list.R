#' @noRd
ade_fetch_datasets <- function(agency_id = "all", resource_id = "all", version = "latest",
                               api_key = ade_api()) {
  url <- paste0(ade_base_url(), "/dataflow/", agency_id, "/", resource_id, "/", version)

  url_xml <- if (grepl("\\?", url)) {
    paste0(url, "&format=xml")
  } else {
    paste0(url, "?format=xml")
  }

  sdmx_dataflows <- rsdmx::readSDMX(
    file = url_xml,
    headers = c(
      `Ocp-Apim-Subscription-Key` = api_key
    )
  )

  dataflows <- sdmx_dataflows@dataflows
  if (length(dataflows) == 0) cli::cli_abort("No datasets returned from {.url {url}}")

  tibble::tibble(
    dataset_id = purrr::map_chr(dataflows, \(d) d@id),
    agency_id = purrr::map_chr(dataflows, \(d) d@agencyID),
    version = purrr::map_chr(dataflows, \(d) d@version),
    description = purrr::map_chr(dataflows, \(d) purrr::pluck(d@Name, "en", .default = NA_character_))
  )
}

#' Get a data frame with information on all available datasets
#'
#' Returns one row per dataset (dataflow) published in the Stats NZ
#' Aotearoa Data Explorer, with columns `dataset_id`, `agency_id`,
#' `version` and `description`.
#'
#' The dataset list is part of the cached metadata database (see
#' [ade_cache_info()]); the first call in a session with no existing
#' cache builds it (a single API request), and every call after that is
#' effectively free.
#'
#' @param refresh Force a rebuild of the metadata cache from the API.
#' @param api_key API key, defaults to [ade_api()].
#'
#' @return A data frame (tibble) of datasets.
#' @export
#' @seealso [ade_search()] to search this list, [ade_dims()] to get the
#'   dimensions of a dataset.
#'
#' @examples
#' \dontrun{
#' datasets <- ade_list()
#' head(datasets)
#' }
ade_list <- function(refresh = FALSE, api_key = ade_api()) {
  ade_get_cache(refresh = refresh, api_key = api_key)$datasets
}

#' Search dataset ids and descriptions
#'
#' Returns the rows of `datasets` whose `dataset_id` or `description`
#' match `string`.
#'
#' @param string A string or regular expression to search for.
#' @param datasets A data frame of datasets to search, as returned by
#'   [ade_list()]. Defaults to [ade_list()] itself, i.e. the full
#'   cached list.
#' @param field Which field(s) to search: `"both"` (default), `"id"`, or
#'   `"description"`.
#' @param ignore_case Whether the search should be case-insensitive
#'   (default `TRUE`).
#'
#' @return A data frame (tibble) of matching datasets.
#' @export
#' @seealso [ade_list()]
#'
#' @examples
#' \dontrun{
#' ade_search("estimate", field = "description")
#' ade_search("POPES_ERP", field = "id")
#' }
ade_search <- function(string,
                       datasets = ade_list(),
                       field = c("both", "id", "description"),
                       ignore_case = TRUE) {
  field <- match.arg(field)

  match_id <- grepl(string, datasets$dataset_id, ignore.case = ignore_case)
  match_desc <- grepl(string, datasets$description, ignore.case = ignore_case)

  keep <- switch(field,
                 both = match_id | match_desc,
                 id = match_id,
                 description = match_desc
  )

  datasets[keep, ]
}
