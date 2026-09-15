#' Get an overview of a dataset
#'
#' Fetches a dataset's name, description, and dimension ids in a single
#' API call. Stats NZ's own dataset descriptions are provided as HTML
#' (headings, notes, links), so by default this renders a formatted page
#' in the RStudio Viewer (or your browser outside RStudio) -- pass
#' `list = TRUE` to get the raw data back instead for programmatic use.
#'
#' Complements [ade_dims()], which focuses on dimensions and their full
#' allowed codes; use this first to get a quick sense of what a dataset
#' actually contains and any caveats Stats NZ has noted about it, before
#' you commit to filtering/downloading it.
#'
#' @param dataset A dataset id, e.g. `"AGR_AGR_003"`.
#' @param list If `TRUE`, return the raw data as a list instead of
#'   rendering it. Default `FALSE`.
#' @param agency_id Agency id. Defaults to `"STATSNZ"`, which covers
#'   every dataset in the Aotearoa Data Explorer.
#' @param api_key API key, defaults to [ade_api()].
#'
#' @return If `list = TRUE`, a list with `id`, `name`, `description` (raw
#'   HTML string from Stats NZ) and `dimensions` (character vector of
#'   dimension ids). If `list = FALSE` (the default), the same data
#'   returned invisibly after being rendered as an HTML page, since the
#'   primary output in that case is the rendered page itself.
#' @export
#' @seealso [ade_dims()] for full dimension/code detail, [ade_list()]
#'   to list datasets.
#'
#' @examples
#' \dontrun{
#' ade_meta("AGR_AGR_003")                    # opens in Viewer
#' ov <- ade_meta("AGR_AGR_003", list = TRUE)
#' ov$name
#' ov$dimensions
#' }
ade_meta <- function(dataset,
                     list = FALSE,
                     agency_id = "STATSNZ",
                     api_key = ade_api()) {
  url <- paste0(
    ade_base_url(), "/dataflow/", agency_id, "/", dataset,
    "?references=all&detail=referencepartial"
  )

  cli::cli_alert_info("Requesting metadata for {.val {dataset}}")
  meta <- tryCatch(
    rsdmx::readSDMX(url, headers = c(`Ocp-Apim-Subscription-Key` = api_key)),
    error = function(e) {
      cli::cli_abort(c(
        "Failed to fetch metadata for {.val {dataset}}.",
        "x" = conditionMessage(e)
      ))
    }
  )

  ds <- meta@datastructures@datastructures[[1]]

  # NOTE: `list` is also this function's argument name, so the
  # constructor below is called via base:: to avoid being masked by the
  # logical argument.
  overview <- base::list(
    id = ds@id,
    name = purrr::pluck(ds@Name, "en", .default = NA_character_),
    description = purrr::pluck(ds@Description, "en", .default = NA_character_),
    dimensions = purrr::map_chr(ds@Components@Dimensions, function(d) d@conceptRef)
  )

  if (list) return(overview)

  ade_view_metadata(overview)
  invisible(overview)
}

#' @noRd
ade_view_metadata <- function(overview) {
  if (!requireNamespace("htmltools", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg htmltools} package is required to render this overview.",
      "i" = "Install it with {.code install.packages(\"htmltools\")}, or use {.code list = TRUE} instead."
    ))
  }

  dims_html <- paste0(
    "<ul>",
    paste0("<li><code>", overview$dimensions, "</code></li>", collapse = ""),
    "</ul>"
  )

  description <- if (is.na(overview$description)) {
    "<p><em>No description provided.</em></p>"
  } else {
    overview$description
  }

  page <- htmltools::tags$html(
    htmltools::tags$head(
      htmltools::tags$meta(charset = "utf-8"),
      htmltools::tags$style(htmltools::HTML(paste0(
        "body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;",
        " max-width: 800px; margin: 2em auto; padding: 0 1em; line-height: 1.55; color: #1a1a1a; }",
        "h1 { font-size: 1.4em; border-bottom: 2px solid #eee; padding-bottom: 0.3em; margin-bottom: 0.1em; }",
        "h4 { margin-top: 1.2em; margin-bottom: 0.3em; color: #444; }",
        "code { background: #f5f5f5; padding: 0.1em 0.4em; border-radius: 3px; }",
        ".dataset-id { color: #888; font-size: 0.9em; margin-bottom: 1.2em; }",
        "a { color: #0969da; }"
      )))
    ),
    htmltools::tags$body(
      htmltools::tags$h1(overview$name),
      htmltools::tags$div(class = "dataset-id", overview$id),
      htmltools::HTML(description),
      htmltools::tags$h4("Dimensions"),
      htmltools::HTML(dims_html)
    )
  )

  htmltools::html_print(page)
}
