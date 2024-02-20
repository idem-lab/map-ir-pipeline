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

  ir_data_subset <- ir_data_moyes_raw %>%
    select(
      bioassay_id,
      country,
      start_month,
      start_year,
      end_month,
      end_year,
      publication_year,
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
    rownames_to_column("uid")


  ir_data_contains_nr <- which_vars_contain(ir_data_subset, "NR")
  ir_data_contains_nf <- which_vars_contain(ir_data_subset, "NF")

  prepared_moyes <- ir_data_subset %>%
  # replace NR values with NA
    mutate(
      across(
        all_of(ir_data_contains_nr),
        \(x) na_if(x, "NR")
      )
    ) %>%
    mutate(
      across(
        all_of(ir_data_contains_nf),
        \(x) na_if(x, "NF")
        )
    ) %>%
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
    ) %>%
    drop_na(
      latitude,
      longitude,
    )

  ## Add a message about dropping observations due to both no_tested/dead being missing

  prepared_moyes

}
