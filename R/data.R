#' @noRd
ade_build_key <- function(dataset, filter, refresh = FALSE) {
  if (is.null(filter) || length(filter) == 0) return("all")

  dims <- ade_dims(dataset, refresh = refresh)$dimensions$dimension

  named <- !is.null(names(filter)) && any(nzchar(names(filter)))

  if (named) {
    unknown <- setdiff(names(filter), dims)
    if (length(unknown) > 0) {
      cli::cli_abort(c(
        paste0("Unknown dimension", if (length(unknown) > 1) "s", " for dataset {.val {dataset}}: {.val {unknown}}"),
        "i" = "Valid dimensions are: {.val {dims}}"
      ))
    }
    segments <- vapply(dims, function(d) {
      val <- filter[[d]]
      if (is.null(val)) "" else paste(val, collapse = "+")
    }, character(1))
  } else {
    if (length(filter) != length(dims)) {
      cli::cli_abort(c(
        "{.arg ...} has {length(filter)} dimension value{?s} but dataset {.val {dataset}} has {length(dims)} dimension{?s}.",
        "i" = "Dimensions, in order: {.val {dims}}",
        "i" = "Either supply one value per dimension (use an empty string or {.code NA} to leave one open), or name the arguments after dimension ids, e.g. {.code FREQ = \"M\"}."
      ))
    }
    segments <- vapply(filter, function(val) {
      if (length(val) == 0 || (length(val) == 1 && (is.na(val) || identical(val, "")))) {
        ""
      } else {
        paste(val, collapse = "+")
      }
    }, character(1))
  }

  # A key where every dimension is wildcarded is semantically "the whole
  # dataset", but the ADE API 404s on a dot-only key (e.g. "...") for
  # larger datasets -- it only accepts the literal "all" shortcut for
  # that. Fall back to it here so a filter that happens to leave every
  # dimension open still works, the same as passing no filter at all.
  if (all(!nzchar(segments))) return("all")

  paste(segments, collapse = ".")
}

#' Extract dimension filters and start_time/end_time out of `...`
#'
#' Internal. `ade_data()` doesn't declare `start_time`/`end_time` as
#' formal arguments -- they're just two conventionally-named values a
#' caller can pass through `...` alongside dimension filters, so this
#' pulls them out and returns what's left as the dimension filter.
#'
#' @param dots The result of `list(...)` from [ade_data()].
#'
#' @return A list with `filter` (the remaining dots, for
#'   `ade_build_key()`), `start_time` and `end_time`.
#' @noRd
ade_split_dots <- function(dots) {
  dot_names <- names(dots)
  if (is.null(dot_names)) dot_names <- rep("", length(dots))

  is_start <- dot_names == "start_time"
  is_end <- dot_names == "end_time"

  list(
    filter = dots[!(is_start | is_end)],
    start_time = if (any(is_start)) dots[[which(is_start)[1]]] else NULL,
    end_time = if (any(is_end)) dots[[which(is_end)[1]]] else NULL
  )
}

#' Download data for a dataset
#'
#' Returns a data frame with the requested data, downloaded through the
#' ADE's SDMX API. The dataset's agency id and version are looked up
#' automatically from the metadata cache, so you only need to supply the
#' dataset id.
#'
#' @param dataset A dataset id, e.g. `"CPI_ALC_001"`.
#' @param ... Controls which series are returned, and (optionally) the
#'   time range. Any combination of:
#'   * **Named dimension filters**, naming the dimensions you want to
#'     filter, e.g. `FREQ = "M", CPI_MEASURE = c("B", "AC")`. Dimensions
#'     you don't name are left open (all codes). See [ade_dims()] for
#'     valid dimension and code ids.
#'   * `start_time` and/or `end_time`, e.g. `start_time = "2020-01-01"`.
#'     Passed through to the API as `startPeriod`/`endPeriod`. Accepted
#'     formats depend on the dataset's frequency (e.g. `"2015"`,
#'     `"2020-Q1"`, `"2022-01"`). Leave both out for all available
#'     observations.
#'   * **Unnamed dimension values**, one per dimension in dataset order
#'     (as in `ade_dims(dataset)$dimensions`), e.g.
#'     `ade_data("CPI_ALC_001", "M", "", "B")`. Use `""` or `NA` to
#'     leave a dimension open. Don't mix this form with named dimension
#'     filters.
#'   * A single **unnamed, pre-formatted key string**, copied from the
#'     ADE web UI's API link (e.g. `"M...B"`) -- set `pre_formatted =
#'     TRUE` when using this form.
#' @param pre_formatted If `TRUE`, `...` must contain exactly one
#'   unnamed element, used as-is as the SDMX query key rather than
#'   being built from dimension names/positions. `start_time` and
#'   `end_time` can still be passed alongside it.
#' @param format SDMX data format. Default `"csvfilewithlabels"`.
#' @param refresh Force a rebuild of the metadata cache from the API
#'   before looking up the dataset's agency id, version and dimensions.
#' @param api_key API key, defaults to [ade_api()].
#'
#' @return A data frame (tibble) of the requested data: column types are
#'   inferred by [readr::read_csv()] and column names are cleaned to
#'   `snake_case`, so the result is ready to pipe straight into further
#'   analysis.
#' @export
#' @seealso [ade_dims()] to find dimension and code ids to filter on,
#'   [ade_list()] to list datasets.
#'
#' @examples
#' \dontrun{
#' # Whole dataset
#' df <- ade_data("CPI_ALC_001")
#'
#' # Filter on named dimensions, with a start time
#' cpi_data <- ade_data(
#'   "CPI_ALC_001",
#'   FREQ = "M",
#'   CPI_MEASURE = "B",
#'   start_time = "2020-01-01"
#' )
#'
#' # Pre-formatted key copied from the ADE web UI
#' df <- ade_data("CPI_ALC_001", "M...B", pre_formatted = TRUE)
#' }
ade_data <- function(dataset,
                     ...,
                     pre_formatted = FALSE,
                     format = "csvfilewithlabels",
                     refresh = FALSE,
                     api_key = ade_api()) {
  parts <- ade_split_dots(list(...))

  if (pre_formatted) {
    if (length(parts$filter) != 1 || !is.null(names(parts$filter))) {
      cli::cli_abort(c(
        "If {.code pre_formatted = TRUE}, {.arg ...} must contain exactly one unnamed pre-formatted key string.",
        "i" = "{.code start_time}/{.code end_time} are still fine alongside it."
      ))
    }
    key <- parts$filter[[1]]
  } else {
    key <- ade_build_key(dataset, parts$filter, refresh = refresh)
  }

  datasets <- ade_list(refresh = refresh, api_key = api_key)
  row <- datasets[datasets$dataset_id == dataset, ]

  if (nrow(row) == 0) {
    cli::cli_abort(c(
      "Dataset {.val {dataset}} not found.",
      "i" = "Try {.fun ade_search} to find the correct id, or {.code ade_list(refresh = TRUE)} to refresh the cache."
    ))
  }

  url <- paste0(
    ade_base_url(), "/data/", row$agency_id[1], ",", dataset, ",", row$version[1], "/", key,
    "?dimensionAtObservation=AllDimensions&format=", format
  )
  if (!is.null(parts$start_time)) url <- paste0(url, "&startPeriod=", parts$start_time)
  if (!is.null(parts$end_time)) url <- paste0(url, "&endPeriod=", parts$end_time)

  cli::cli_alert_info("Fetching data for {.val {dataset}}")

  resp <- ade_request(url, api_key) |> httr2::req_perform()
  out <- readr::read_csv(httr2::resp_body_string(resp), show_col_types = FALSE)
  names(out) <- ade_clean_names(names(out))
  out
}
