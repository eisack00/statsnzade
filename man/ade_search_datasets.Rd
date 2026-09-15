% Generated manually to match roxygen2 output -- regenerate with roxygen2::roxygenise()
\name{ade_search_datasets}
\alias{ade_search_datasets}
\title{Search dataset ids and descriptions}
\usage{
ade_search_datasets(
  string,
  datasets = ade_datasets(),
  field = c("both", "id", "description"),
  ignore_case = TRUE
)
}
\arguments{
\item{string}{A string or regular expression to search for.}

\item{datasets}{A data frame of datasets to search, as returned by
\code{\link{ade_datasets}}. Defaults to \code{\link{ade_datasets}}
itself, i.e. the full cached list.}

\item{field}{Which field(s) to search: \code{"both"} (default),
\code{"id"}, or \code{"description"}.}

\item{ignore_case}{Whether the search should be case-insensitive
(default \code{TRUE}).}
}
\value{
A data frame (tibble) of matching datasets.
}
\description{
Returns the rows of \code{datasets} whose \code{dataset_id} or
\code{description} match \code{string}.
}
\examples{
\dontrun{
ade_search_datasets("food price")
ade_search_datasets("CPI_FPI", field = "id")
}
}
\seealso{
\code{\link{ade_datasets}}
}
