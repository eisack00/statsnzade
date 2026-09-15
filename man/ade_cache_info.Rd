% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_cache_info}
\alias{ade_cache_info}
\title{Inspect the local metadata cache}
\usage{
ade_cache_info()
}
\value{
An invisible list with \code{path} (character), \code{exists}
(logical), \code{built_at} (\code{POSIXct} or \code{NA}), and
\code{n_datasets} (integer or \code{NA}). Also printed to the console.
}
\description{
Reports whether a cached metadata database exists, where it lives,
and when it was last built, without triggering a rebuild.
}
\examples{
\dontrun{
ade_cache_info()
}
}
