% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_api_key}
\alias{ade_api_key}
\title{Get the API key that will be used for requests}
\usage{
ade_api_key()
}
\value{
A character string.
}
\description{
Returns the key set with \code{\link{ade_set_api_key}}, falling back
to the \code{SNZ_PRIMARY_KEY} environment variable. Errors if neither
is set.
}
\examples{
\dontrun{
ade_api_key()
}
}
