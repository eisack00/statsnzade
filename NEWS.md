# statsnzade 0.1.0

* Initial release.
* `ade_list()` lists all dataflows published in the Aotearoa Data
  Explorer (ADE).
* `ade_search()` searches dataset ids and descriptions.
* `ade_dims()` returns a dataset's dimensions and allowed codes.
* `ade_data()` downloads data for a dataset, with optional dimension
  filters and time-window arguments.
* `ade_meta()` gets a dataset's name, description, and dimension ids,
  and renders them as a browsable overview in the Viewer (or returns
  the raw data with `list = TRUE`).
* Dataset and dimension metadata are cached locally in a small SQLite
  database (`ade_cache_info()`, `ade_cache_refresh()`,
  `ade_cache_clear()`) so repeated lookups avoid repeated API calls.
