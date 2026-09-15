% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_data_structure}
\alias{ade_data_structure}
\title{Get the data structure of a dataset}
\usage{
ade_data_structure(dataset, refresh = FALSE)
}
\arguments{
\item{dataset}{A dataset id, e.g. \code{"CPI_ALC_001"}.}

\item{refresh}{Force a rebuild of the metadata cache from the API.}
}
\value{
A named list of data frames: \code{dimensions} (one row per
dimension, with columns \code{dimension} and \code{description}),
plus one further data frame per dimension (named after the dimension
id) with columns \code{id} and \code{label} giving its allowed codes.
}
\description{
Returns the dimensions of a dataset and, for each dimension, the
codes Stats NZ allows for it (as defined by an \code{Allowed} content
constraint on the dataset -- see the ADE metadata guidance for
details). This is the information you need to build a \code{filter}
for \code{\link{ade_dataset}}.
}
\examples{
\dontrun{
str <- ade_data_structure("CPI_ALC_001")
str$dimensions
str$CPI_MEASURE
}
}
\seealso{
\code{\link{ade_dataset}} to download data using this structure,
\code{\link{ade_datasets}} to list datasets.
}
