#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param nameme1
#' @return
#' @author njtierney
#' @export
get_landcover <- function(var = "trees", subset_country_codes) {

  the_raster <- landcover(
    var = var,
    path = "data/rasters"
  )

  crop_raster_to_country(the_raster, subset_country_codes)

}
