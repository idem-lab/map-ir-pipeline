#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param subset_country_codes
#' @return
#' @author njtierney
#' @export
get_worldclim <- function(subset_country_codes, var) {

  worldclim_country(
    country = subset_country_codes$ISO3,
    var = var,
    path = "data/rasters/"
  )

}
