% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_cache_clear}
\alias{ade_cache_clear}
\title{Clear the local metadata cache}
\usage{
ade_cache_clear()
}
\value{
\code{TRUE}, invisibly.
}
\description{
Deletes the cached SQLite database and the in-memory copy for this
session. The next call to a \code{statsnzade} function that needs
metadata will rebuild it from the API.
}
\examples{
\dontrun{
ade_cache_clear()
}
}
