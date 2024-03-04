#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param crop
#' @return
#' @author njtierney
#' @export
agcrop_area <- function(crop = "acof") {
  the_raster <- crop_spam(
    crop = crop,
    var = "area",
    path = "data/rasters",
    africa = TRUE
  )

  the_raster
}
