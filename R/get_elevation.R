#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param subset_country_codes
#' @return
#' @author njtierney
#' @export
get_elevation <- function(subset_country_codes) {
  elevation_30s(
    country = subset_country_codes$ISO3,
    path = "data/rasters/"
  )
}
