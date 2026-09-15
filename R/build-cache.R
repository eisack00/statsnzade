#' Fetch and reshape the dimension/code metadata for one dataset
#'
#' Internal. Fetches a single dataset's metadata bundle (data structure
#' definition, codelists filtered to *allowed* codes, and concepts) with
#' a single `references=descendants&detail=referencepartial` query, then
#' reshapes it to one row per dimension x allowed code. Called by
#' [ade_dims()]; not cached to disk.
#'
#' @param dataset_id A dataset id.
#' @param agency_id The dataset's agency id (from [ade_list()]).
#' @param version The dataset's version (from [ade_list()]).
#' @param api_key API key.
#'
#' @return A tibble with columns `dataset_id`, `dimension`,
#'   `dimension_description`, `code_value`, `code_description`.
#' @noRd
ade_fetch_dataset_structure <- function(dataset_id, agency_id, version, api_key) {
  url <- paste0(
    ade_base_url(), "/dataflow/", agency_id, "/", dataset_id, "/", version,
    "?references=descendants&detail=referencepartial"
  )

  sdmx_meta <- rsdmx::readSDMX(file = url, headers = c(`Ocp-Apim-Subscription-Key` = api_key))

  dsd <- sdmx_meta@datastructures@datastructures[[1]]
  codelists <- sdmx_meta@codelists@codelists
  concepts <- sdmx_meta@concepts@concepts

  codelist_rows <- purrr::map(codelists, function(cl) {
    tibble::tibble(codelist_id = cl@id, codelist = list(cl))
  }) |> purrr::list_rbind()

  concept_rows <- purrr::map(concepts, function(cn) {
    tibble::tibble(
      concept_id = cn@id,
      concept_name = purrr::pluck(cn@Name, "en", .default = NA_character_)
    )
  }) |> purrr::list_rbind()

  dim_rows <- purrr::map(dsd@Components@Dimensions, function(d) {
    tibble::tibble(dimension = d@conceptRef, dim_codelist_id = d@codelist)
  }) |> purrr::list_rbind()

  dim_rows |>
    dplyr::left_join(codelist_rows, by = c("dim_codelist_id" = "codelist_id")) |>
    dplyr::left_join(concept_rows, by = c("dimension" = "concept_id")) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      dimension_description = concept_name,
      codes = list(if (is.null(codelist)) list() else codelist@Code)
    ) |>
    dplyr::ungroup() |>
    tidyr::unnest_longer(codes, keep_empty = TRUE) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      code_value = if (is.null(codes)) NA_character_ else codes@id,
      code_description = if (is.null(codes)) NA_character_ else purrr::pluck(codes@label, "en", .default = NA_character_)
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(dataset_id = dataset_id, .before = 1) |>
    dplyr::select(dataset_id, dimension, dimension_description, code_value, code_description)
}
