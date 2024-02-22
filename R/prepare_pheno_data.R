#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_moyes_raw
#' @return
#' @author njtierney
#' @export
prepare_pheno_data <- function(moyes_pheno_raw, gambiae_complex_list) {

  ir_data_subset <- moyes_pheno_raw %>%
    select(
      country,
      start_month,
      start_year,
      end_month,
      end_year,
      latitude,
      longitude,
      species,
      no_mosquitoes_tested,
      no_mosquitoes_dead,
      percent_mortality,
      species,
      insecticide_class
    )

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
    filter(
      species %in% gambiae_complex_list
    )  %>%
    # since they are all the same species
    select(
      -species
    ) %>%
    mutate(
      start_year = as.integer(start_year)
    ) %>%
    drop_na(
      latitude,
      longitude,
    ) %>%
    rename(
      insecticide = insecticide_class
    )

  ## Add a message about dropping observations due to both no_tested/dead being missing

  prepared_moyes

}
