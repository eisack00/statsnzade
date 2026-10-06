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
Explorer (ADE) SDMX API. Use it to list datasets, inspect their
structure, and download data.

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

ade_search("estimate", field = "description")
ade_search("population estimate", field = "description")
```

These searches can help find relevant dataset IDs, such as
`POPES_ERP_008` for subnational population estimates.

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
pop_dims <- ade_dims("POPES_ERP_008")
pop_dims$dimensions
pop_dims$AREA_POPES_ERP_008
pop_dims$YEAR_POPES_ERP_008
```

For example, `RC9999` represents total New Zealand by regional councils,
and `2023` selects the year at 30 June 2023.

## Downloading data

```{r}
# Whole dataset
population <- ade_data("POPES_ERP_008")

# New Zealand estimates for 2023 across the other dimensions
population_2023 <- ade_data(
  "POPES_ERP_008",
  AREA_POPES_ERP_008 = "RC9999",
  YEAR_POPES_ERP_008 = "2023"
)
```

## Exploring dataset metadata interactively

```{r}
ade_meta("POPES_ERP_008")
```

By default this renders the dataset's name, description, and dimensions
as a page in the RStudio Viewer (or your browser outside RStudio). Pass
`list = TRUE` to get the raw data back instead:

```{r}
overview <- ade_meta("POPES_ERP_008", list = TRUE)
overview$name
overview$dimensions
```

## A caveat inherited from the API

Allowed codes (what you get from `ade_dims()`) are defined
**one dimension at a time**. They don't tell you which *combinations* of
codes across dimensions actually occur in the data. To check that, query
`ade_data()` and inspect the series that come back, or request
`detail=serieskeysonly` directly against the data endpoint.
