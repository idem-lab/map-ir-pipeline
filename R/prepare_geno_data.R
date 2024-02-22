#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_geno_raw
#' @return
#' @author njtierney
#' @export
prepare_geno_data <- function(moyes_geno_raw) {

  moyes_geno_raw %>%
    rowid_to_column("uid") %>%
    select(
      kdr_test_id,
      start_month,
      start_year,
      end_month,
      end_year,
      publication_year,
      site_name,
      latitude,
      longitude,
      no_mosquitoes_tested,
      anophelines_tested,
      # no mosquitoes dead?
      # no percent mortality?
      identification_method_1,
      identification_method_2,
      generation,
      insecticide_tested
    ) %>%
    mutate(
      type = "genotypic"
    )

}
