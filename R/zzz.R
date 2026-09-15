.onLoad <- function(libname, pkgname) {
  op <- options()
  op_defaults <- list(
    statsnzade.base_url = "https://api.data.stats.govt.nz/rest"
  )
  to_set <- setdiff(names(op_defaults), names(op))
  if (length(to_set) > 0) options(op_defaults[to_set])
  invisible()
}