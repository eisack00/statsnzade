% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_browse_metadata}
\alias{ade_browse_metadata}
\title{Browse a dataset on the Aotearoa Data Explorer website}
\usage{
ade_browse_metadata(dataset)
}
\arguments{
\item{dataset}{A dataset id, e.g. \code{"CPI_ALC_001"}.}
}
\value{
The URL, invisibly.
}
\description{
Opens the dataset's page on the Aotearoa Data Explorer in your
default web browser, where you can explore its metadata,
documentation and data interactively.
}
\examples{
\dontrun{
ade_browse_metadata("CPI_ALC_001")
}
}
