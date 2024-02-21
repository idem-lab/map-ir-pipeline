#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param crop
#' @return
#' @author njtierney
#' @export
agcrop_area <- function(crop = "acof", subset_country_codes) {

  the_raster <- crop_spam(
    crop = crop,
    var = "area",
    path = "data/rasters",
    africa = TRUE
  )

  crop_raster_to_country(the_raster, subset_country_codes)


}
