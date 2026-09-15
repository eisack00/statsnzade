% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_dataset}
\alias{ade_dataset}
\title{Download data for a dataset}
\usage{
ade_dataset(
  dataset,
  filter = NULL,
  start_time = NULL,
  end_time = NULL,
  pre_formatted = FALSE,
  format = "csvfilewithlabels",
  refresh = FALSE,
  api_key = ade_api_key(),
  ...
)
}
\arguments{
\item{dataset}{A dataset id, e.g. \code{"CPI_ALC_001"}.}

\item{filter}{Controls which series are returned. One of:
\itemize{
\item \code{NULL} (default): the whole dataset.
\item A \strong{named list}, naming the dimensions you want to filter, e.g.
\code{list(FREQ = "M", CPI_MEASURE = c("B", "AC"))}. Unnamed
dimensions are left open (all codes). See \code{\link{ade_data_structure}}
for valid dimension and code ids.
\item An \strong{unnamed list}, with one element per dimension in dataset
order (as in \code{ade_data_structure()$dimensions}), e.g.
\code{list("M", "", "B")}. Use \code{""} or \code{NA} to leave a
dimension open.
\item A single pre-formatted key string copied from the ADE web UI's
API link (e.g. \code{"M.CPI_Q09B.B"}) -- set \code{pre_formatted = TRUE}
when using this form.
}}

\item{start_time, end_time}{Optional start/end period filters (e.g.
\code{"2015"}, \code{"2020-Q1"}, \code{"2022-01"}, depending on the
dataset's frequency). Passed through to the API as
\code{startPeriod}/\code{endPeriod}. If left blank, all available
observations are returned.}

\item{pre_formatted}{If \code{TRUE}, \code{filter} is used as-is as
the SDMX query key rather than being built from dimension
names/positions.}

\item{format}{SDMX data format. Default \code{"csvfilewithlabels"}.}

\item{refresh}{Force a rebuild of the metadata cache from the API
before looking up the dataset's agency id, version and dimensions.}

\item{api_key}{API key, defaults to \code{\link{ade_api_key}}.}

\item{...}{Additional arguments passed on to \code{\link[readr]{read_csv}}.}
}
\value{
A data frame (tibble) of the requested data.
}
\description{
Returns a data frame with the requested data, downloaded through the
ADE's SDMX API. The dataset's agency id and version are looked up
automatically from the metadata cache, so you only need to supply the
dataset id.
}
\examples{
\dontrun{
# Whole dataset
df <- ade_dataset("CPI_ALC_001")

# Filter on named dimensions
df <- ade_dataset(
  "CPI_ALC_001",
  filter = list(FREQ = "M", CPI_MEASURE = "B"),
  start_time = "2015"
)

# Pre-formatted key copied from the ADE web UI
df <- ade_dataset("CPI_ALC_001", filter = "M...B", pre_formatted = TRUE)
}
}
\seealso{
\code{\link{ade_data_structure}} to find dimension and code ids to
filter on, \code{\link{ade_datasets}} to list datasets.
}
