% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_datasets}
\alias{ade_datasets}
\title{Get a data frame with information on all available datasets}
\usage{
ade_datasets(refresh = FALSE, api_key = ade_api_key())
}
\arguments{
\item{refresh}{Force a rebuild of the metadata cache from the API.}

\item{api_key}{API key, defaults to \code{\link{ade_api_key}}.}
}
\value{
A data frame (tibble) of datasets.
}
\description{
Returns one row per dataset (dataflow) published in the Stats NZ
Aotearoa Data Explorer, with columns \code{dataset_id},
\code{agency_id}, \code{version} and \code{description}.
}
\details{
The dataset list is part of the cached metadata database (see
\code{\link{ade_cache_info}}); the first call in a session with no
existing cache builds it (which takes a little while, since it also
fetches every dataset's dimensions and codes), and every call after
that is effectively free.
}
\examples{
\dontrun{
datasets <- ade_datasets()
head(datasets)
}
}
\seealso{
\code{\link{ade_search_datasets}} to search this list,
\code{\link{ade_data_structure}} to get the dimensions of a dataset.
}
