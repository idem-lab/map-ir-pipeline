#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param subset_country_codes
#' @return
#' @author njtierney
#' @export
get_shapefile <- function(subset_country_codes) {
  shapefile <- gadm(
    country = subset_country_codes$ISO3,
    level = 0,
    path = tempdir(),
    version = "4.1",
    resolution = 2
  )

  shapefile
}
