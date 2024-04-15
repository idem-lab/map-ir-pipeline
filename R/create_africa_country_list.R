#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
create_africa_country_list <- function() {

  afriadmin::afcountries |>
    mutate(
      alt_name = countrycode(
        sourcevar = iso3c,
        origin = "iso3c",
        destination = "country.name"
      ),
      .after = name
    ) |>
    relocate(iso3c) |>
    as_tibble()


}
