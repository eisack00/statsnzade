#' @noRd
ade_cache_path <- function() {
  dir <- tools::R_user_dir("statsnzade", which = "cache")
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  file.path(dir, "statsnzade.sqlite")
}

#' @noRd
ade_cache_write <- function(cache) {
  path <- ade_cache_path()
  con <- DBI::dbConnect(RSQLite::SQLite(), path)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  DBI::dbWriteTable(con, "datasets", cache$datasets, overwrite = TRUE)
  DBI::dbWriteTable(
    con, "meta",
    data.frame(built_at = as.character(cache$built_at), stringsAsFactors = FALSE),
    overwrite = TRUE
  )
  invisible(path)
}

#' @noRd
ade_cache_read <- function() {
  path <- ade_cache_path()
  con <- DBI::dbConnect(RSQLite::SQLite(), path)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  list(
    datasets = tibble::as_tibble(DBI::dbReadTable(con, "datasets")),
    built_at = as.POSIXct(DBI::dbReadTable(con, "meta")$built_at[1])
  )
}

#' Get the cached dataset list, building it if necessary
#'
#' The gate that [ade_list()] goes through. On the very first call (no
#' cache file yet), or whenever `refresh = TRUE`, this fetches the full
#' dataset list from the API (a single request) and writes it to a
#' local SQLite file. Every subsequent call reads from an in-memory copy
#' for the rest of the session; new sessions read the SQLite file
#' instead of calling the API again.
#'
#' Dimension/code metadata is *not* part of this cache -- see
#' [ade_dims()], which fetches per dataset on demand.
#'
#' @param refresh Force a rebuild from the API.
#' @param api_key API key.
#' @param quiet Suppress progress output while building.
#'
#' @return A list with `datasets` and `built_at`.
#' @noRd
ade_get_cache <- function(refresh = FALSE, api_key = ade_api(), quiet = FALSE) {
  if (!refresh && !is.null(the$cache)) {
    return(the$cache)
  }

  if (!refresh && file.exists(ade_cache_path())) {
    cache <- ade_cache_read()
    the$cache <- cache
    return(cache)
  }

  datasets <- ade_fetch_datasets(api_key = api_key)
  cache <- list(datasets = datasets, built_at = Sys.time())
  ade_cache_write(cache)
  the$cache <- cache

  if (!quiet) {
    cli::cli_alert_success(
      "Cached {nrow(cache$datasets)} dataset{?s} at {.path {ade_cache_path()}}"
    )
  }

  cache
}

#' Inspect the local metadata cache
#'
#' Reports whether a cached dataset list exists, where it lives, and
#' when it was last built, without triggering a rebuild.
#'
#' @return An invisible list with `path` (character), `exists`
#'   (logical), `built_at` (`POSIXct` or `NA`), and `n_datasets`
#'   (integer or `NA`). Also printed to the console.
#' @export
#'
#' @examples
#' \dontrun{
#' ade_cache_info()
#' }
ade_cache_info <- function() {
  path <- ade_cache_path()
  exists <- file.exists(path)

  if (exists) {
    cache <- if (!is.null(the$cache)) the$cache else ade_cache_read()
    built_at <- cache$built_at
    n_datasets <- nrow(cache$datasets)
  } else {
    built_at <- as.POSIXct(NA)
    n_datasets <- NA_integer_
  }

  cli::cli_h3("statsnzade metadata cache")
  cli::cli_bullets(c(
    "*" = "Path: {.path {path}}",
    "*" = if (exists) "Built: {built_at}" else "Not yet built",
    "*" = if (exists) "Datasets cached: {n_datasets}" else NULL
  ))

  invisible(list(path = path, exists = exists, built_at = built_at, n_datasets = n_datasets))
}

#' Refresh the local dataset list cache
#'
#' Rebuilds the cached dataset list from the API and overwrites the
#' local cache. This does not touch any dimension/code lookups done via
#' [ade_dims()], which are always fetched fresh (with a lightweight
#' in-session cache) -- see its `refresh` argument if you need to bust
#' that instead.
#'
#' @param api_key API key, defaults to [ade_api()].
#' @param quiet Suppress progress output.
#'
#' @return The refreshed cache, invisibly (a list with `datasets` and
#'   `built_at`).
#' @export
#'
#' @examples
#' \dontrun{
#' ade_cache_refresh()
#' }
ade_cache_refresh <- function(api_key = ade_api(), quiet = FALSE) {
  invisible(ade_get_cache(refresh = TRUE, api_key = api_key, quiet = quiet))
}

#' Clear the local metadata cache
#'
#' Deletes the cached SQLite database and the in-memory copies for this
#' session (both the dataset list and any cached dimension structures).
#' The next call to a `statsnzade` function that needs metadata will
#' rebuild it from the API.
#'
#' @return `TRUE`, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' ade_cache_clear()
#' }
ade_cache_clear <- function() {
  path <- ade_cache_path()
  if (file.exists(path)) {
    file.remove(path)
    cli::cli_alert_success("Removed cached database at {.path {path}}")
  } else {
    cli::cli_alert_info("No cached database to remove.")
  }
  the$cache <- NULL
  the$structures <- NULL
  invisible(TRUE)
}
