#' statsnzade: Search and Extract Data from the Stats NZ Aotearoa Data
#' Explorer
#'
#' `statsnzade` provides a small set of functions for discovering and
#' downloading data from Stats NZ's [Aotearoa Data Explorer](https://explore.data.stats.govt.nz/)
#' (ADE) SDMX API, following the same shape as similar packages for other
#' national statistics agencies (e.g. the `cancensus`, `OECD` and
#' `rsdmx` packages):
#'
#' * [ade_list()] lists every available dataset.
#' * [ade_search()] searches dataset ids and descriptions.
#' * [ade_dims()] returns a dataset's dimensions and their allowed
#'   codes.
#' * [ade_data()] downloads data, optionally filtered by dimension
#'   codes and/or a time range.
#' * [ade_meta()] gets a dataset's name, description, and dimension
#'   ids, and renders them as a browsable overview.
#'
#' Dataset and dimension metadata changes rarely but is expensive to
#' fetch, so it is cached locally the first time it's needed; see
#' [ade_cache_info()].
#'
#' @section Authentication:
#' Requests to the ADE API require a subscription key. Set it once per
#' session with [ade_api()], or set the `SNZ_PRIMARY_KEY` environment
#' variable (e.g. in `.Renviron`) so it's picked up automatically.
#'
#' Subscribe to Stats NZ Aotearoa Data Explorer at
#' <https://portal.apis.stats.govt.nz/>
#'
#' @section Disclaimer:
#' This is an unofficial client for the Stats NZ Aotearoa Data Explorer
#' API, not developed or endorsed by Stats NZ -- Tatauranga Aotearoa.
#' Data retrieved through this package is subject to Stats NZ's own
#' licensing and terms of use; see
#' <https://explore.data.stats.govt.nz/> for authoritative figures and
#' terms.
#'
#' @keywords internal
"_PACKAGE"
