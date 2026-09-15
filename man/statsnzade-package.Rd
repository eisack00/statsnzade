% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{statsnzade-package}
\alias{statsnzade-package}
\alias{statsnzade}
\docType{package}
\title{statsnzade: Search and Extract Data from the Stats NZ Aotearoa Data Explorer}
\description{
\code{statsnzade} provides a small set of functions for discovering and
retrieving data from Stats NZ's Aotearoa Data Explorer (ADE) SDMX API,
following the same general shape as similar packages for national
statistics agencies (e.g. \code{OECD} and \code{rsdmx}):
\itemize{
\item \code{\link{ade_list}} lists every available dataset.
\item \code{\link{ade_search}} searches dataset ids and descriptions.
\item \code{\link{ade_dims}} returns a dataset's dimensions and allowed codes.
\item \code{\link{ade_data}} downloads data, optionally filtered by dimension codes and time window.
\item \code{\link{ade_meta}} returns an overview of a dataset and renders it in the Viewer by default.
}

Dataset and dimension metadata changes rarely but is expensive to
fetch, so it is cached locally the first time it's needed; see
\code{\link{ade_cache_info}}.
}
\section{Authentication}{
Requests to the ADE API require a subscription key. Set it once per
session with \code{\link{ade_api}}, or set the
\code{SNZ_PRIMARY_KEY} environment variable (e.g. in \code{.Renviron})
so it's picked up automatically.
}
\keyword{internal}
