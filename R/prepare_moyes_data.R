#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_moyes_raw
#' @return
#' @author njtierney
#' @export
prepare_moyes_data <- function(ir_data_moyes_raw) {

  prepared_moyes <- ir_data_moyes_raw %>%
    select(
      bioassay_id,
      country,
      site_name,
      latitude,
      longitude,
      species,
      no_mosquitoes_tested,
      no_mosquitoes_dead,
      percent_mortality,
      species,
      identification_method_1,
      identification_method_2,
      generation,
      insecticide_class,
      insecticide_tested
    ) %>%
    rownames_to_column("uid") %>%
    mutate(
      across(
        c(
          latitude,
          longitude,
          no_mosquitoes_dead,
          no_mosquitoes_tested
        ),
        as.numeric
      )
    )

  prepared_moyes
}
