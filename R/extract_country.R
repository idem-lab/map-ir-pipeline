#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_geno_geocode
#' @return
#' @author njtierney
#' @export
extract_country <- function(moyes_geno_geocode) {
  moyes_geno_geocode %>%
    mutate(
      country_name = countrycode(
        sourcevar = country_code,
        origin = "iso2c",
        destination = "country.name"
      ),
      country_iso3 = countrycode(
        sourcevar = country_code,
        origin = "iso2c",
        destination = "iso3c"
      ),
      .after = country_code
    )
}
