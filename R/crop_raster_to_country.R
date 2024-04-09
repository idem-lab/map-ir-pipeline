#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param crop_coffee_data
#' @param subset_country_codes
#' @return
#' @author njtierney
#' @export
crop_raster_to_country <- function(raster, reference) {

  cropped <- crop(
    x = raster,
    y = reference,
    mask = TRUE
  )

  cropped
}
