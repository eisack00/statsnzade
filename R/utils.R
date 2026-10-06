# Internal state ----------------------------------------------------------
#
# `the` holds an in-memory copy of the cached metadata for the current R
# session, so that repeated calls within a session don't even need to
# touch the SQLite cache file. The SQLite file itself (see
# `ade_cache_path()`) is what makes the cache persist *between* sessions.
the <- new.env(parent = emptyenv())

#' @noRd
ade_base_url <- function() {
  getOption("statsnzade.base_url", "https://api.data.stats.govt.nz/rest")
}

#' @noRd
ade_check_key <- function(api_key) {
  if (is.null(api_key) || !nzchar(api_key)) {
    cli::cli_abort(c(
      "No Stats NZ API key found.",
      "i" = "Set one with {.fun ade_api}, or set the {.envvar SNZ_PRIMARY_KEY} environment variable."
    ))
  }
  invisible(api_key)
}

#' @noRd
ade_request <- function(url, api_key) {
  httr2::request(url) |>
    httr2::req_headers(`Ocp-Apim-Subscription-Key` = api_key) |>
    httr2::req_user_agent("statsnzade (https://github.com/yourname/statsnzade)")
}

#' Clean up SDMX-CSV column names into snake_case
#'
#' `ade_data()`'s API responses come back with the ADE's own column
#' naming (a mix of upper case, spaces and punctuation, e.g.
#' `"AREA_POPES_ERP_008: Area"` or `"Data value"`). This tidies them up
#' so the result is pipeline-ready without the user having to rename
#' columns themselves.
#'
#' @param x A character vector of column names.
#'
#' @return A character vector of the same length, in `snake_case`.
#' @noRd
ade_clean_names <- function(x) {
  x <- gsub("[^A-Za-z0-9]+", "_", x)
  x <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", x)
  x <- tolower(x)
  x <- gsub("_+", "_", x)
  x <- gsub("^_|_$", "", x)
  x
}
