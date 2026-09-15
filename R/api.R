#' Get or set your Stats NZ API key
#'
#' Requests to the Aotearoa Data Explorer (ADE) API require a
#' subscription key. Call `ade_api("your-key")` once per session to set
#' it, or, better for reproducibility, set the `SNZ_PRIMARY_KEY`
#' environment variable (e.g. in your `.Renviron` file) so it's picked
#' up automatically and you never write it into a script.
#'
#' Call `ade_api()` with no arguments to retrieve the key that's
#' currently active -- this is what every other function in the package
#' uses by default, so you'll rarely need to call it directly yourself.
#'
#' @param key A Stats NZ ADE subscription key. Omit to retrieve the
#'   currently active key instead of setting a new one.
#'
#' @return If `key` is supplied: the key, invisibly. If `key` is
#'   omitted: the currently active key (whichever was set most
#'   recently with `ade_api()`, falling back to `SNZ_PRIMARY_KEY`),
#'   returned visibly. Errors if no key is available either way.
#' @export
#'
#' @examples
#' \dontrun{
#' # Set a key for the session
#' ade_api("your-subscription-key")
#'
#' # Retrieve the currently active key
#' ade_api()
#' }
ade_api <- function(key = NULL) {
  if (!is.null(key)) {
    stopifnot(is.character(key), length(key) == 1L, nzchar(key))
    options(statsnzade.api_key = key)
    return(invisible(key))
  }

  active_key <- getOption("statsnzade.api_key", "")
  if (!nzchar(active_key)) active_key <- Sys.getenv("SNZ_PRIMARY_KEY", "")
  ade_check_key(active_key)
  active_key
}
