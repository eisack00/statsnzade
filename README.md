---
title: "Introduction to statsnzade"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Introduction to statsnzade}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)
```

`statsnzade` searches and extracts data from Stats NZ's Aotearoa Data
Explorer (ADE) SDMX API. It follows the same shape as packages like
`OECD` and `rsdmx`: list datasets, inspect their structure, then
download data.

```{r setup}
library(statsnzade)
```

## Authentication

Every request needs a Stats NZ subscription key. Set the
`SNZ_PRIMARY_KEY` environment variable (e.g. in `.Renviron`) so it's
picked up automatically, or set it for the current session:

```{r}
ade_api("your-subscription-key")
```

## Listing and searching datasets

```{r}
datasets <- ade_list()
head(datasets)

ade_search("food price")
```

The first call to `ade_list()` (or any other `statsnzade` function that
needs metadata) builds a local cache from the ADE metadata. Every call
after that, including in future sessions, reads that cached metadata
instead:

```{r}
ade_cache_info()
```

Force a rebuild if you know Stats NZ has published or changed a dataset:

```{r}
ade_cache_refresh()
```

## Inspecting a dataset's structure

```{r}
str <- ade_dims("CPI_ALC_001")
str$dimensions
str$CPI_MEASURE
```

## Downloading data

```{r}
# Whole dataset
cpi <- ade_data("CPI_ALC_001")

# Filtered by dimension code and a time period
cpi_index <- ade_data(
  "CPI_ALC_001",
  FREQ = "M",
  CPI_MEASURE = "B",
  start_time = "2015"
)
```

## Exploring dataset metadata interactively

```{r}
ade_meta("CPI_ALC_001")
```

By default this renders the dataset's name, description, and dimensions
as a page in the RStudio Viewer (or your browser outside RStudio). Pass
`list = TRUE` to get the raw data back instead:

```{r}
ov <- ade_meta("CPI_ALC_001", list = TRUE)
ov$name
ov$dimensions
```

## A caveat inherited from the API

Allowed codes (what you get from `ade_dims()`) are defined
**one dimension at a time**. They don't tell you which *combinations* of
codes across dimensions actually occur in the data. To check that, query
`ade_data()` and inspect the series that come back, or request
`detail=serieskeysonly` directly against the data endpoint.
