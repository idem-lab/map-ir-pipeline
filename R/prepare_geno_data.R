#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_geno_raw
#' @return
#' @author njtierney
#' @export
prepare_geno_data <- function(moyes_geno_raw, moyes_geno_countries) {
  # add the country information
  countries <- moyes_geno_countries %>%
    select(
      country = country_name
    )

  moyes_geno_raw %>%
    bind_cols(
      countries,
    ) %>%
    # make this id after the data have been combined
    select(
      country,
      start_month,
      start_year,
      end_month,
      end_year,
      latitude,
      longitude,
      # species - filter down to "gambaie complex" in complex_subgroup
      no_mosquitoes_tested,
      # percent mortality? - instead we are using: l1014l_percent
      percent_mortality = l1014l_percent,
      complex_subgroup
      # no information on insecticide
    ) %>%
    # just keep Gambiae
    filter(
      complex_subgroup == "Gambiae Complex"
    ) %>%
    select(
      -complex_subgroup
    ) %>%
    mutate(
      no_mosquitoes_dead = no_mosquitoes_tested * (percent_mortality / 100),
      insecticide = "none"
    ) %>%
    relocate(
      country,
      start_month,
      start_year,
      end_month,
      end_year,
      latitude,
      longitude,
      no_mosquitoes_tested,
      no_mosquitoes_dead,
      percent_mortality,
      insecticide
    ) %>%
    mutate(
      start_year = as.integer(start_year)
    ) %>%
    mutate(
      across(
        c(
          latitude,
          longitude
        ),
        as.numeric
      )
    )
}
