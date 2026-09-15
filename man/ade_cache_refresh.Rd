% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_cache_refresh}
\alias{ade_cache_refresh}
\title{Refresh the local metadata cache}
\usage{
ade_cache_refresh(api_key = ade_api_key(), quiet = FALSE)
}
\arguments{
\item{api_key}{API key, defaults to \code{\link{ade_api_key}}.}

\item{quiet}{Suppress progress output.}
}
\value{
The refreshed cache, invisibly (a list with \code{datasets},
\code{codes} and \code{built_at}).
}
\description{
Rebuilds the cached dataset/dimension/code metadata database from the
API and overwrites the local cache. Metadata changes rarely, so you
typically only need this if you know Stats NZ has published or
updated a dataset since your cache was built.
}
\examples{
\dontrun{
ade_cache_refresh()
}
}
