#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param subset_country_codes
#' @return
#' @author njtierney
#' @export
get_country_shape <- function(subset_country_codes) {

  my_shape <- gadm(
    country = subset_country_codes$ISO3,
    level = 0,
    path = "data/shapefiles",
    version = "4.1",
    # low res
    resolution = 2
  )



}
