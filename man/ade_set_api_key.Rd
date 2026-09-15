% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_set_api_key}
\alias{ade_set_api_key}
\title{Set your Stats NZ API key}
\usage{
ade_set_api_key(key)
}
\arguments{
\item{key}{A Stats NZ ADE subscription key.}
}
\value{
The key, invisibly.
}
\description{
Requests to the Aotearoa Data Explorer (ADE) API require a
subscription key. Call this once per session to set it, or, better
for reproducibility, set the \code{SNZ_PRIMARY_KEY} environment
variable (e.g. in your \code{.Renviron} file) so it's picked up
automatically and you never write it into a script.
}
\examples{
\dontrun{
ade_set_api_key("your-subscription-key")
}
}
