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
crop_raster_to_country <- function(crop_coffee_data, subset_country_codes) {

  shapefile <- get_shapefile(subset_country_codes)

  cropped <- crop(
    x = crop_coffee_data,
    y = shapefile,
    mask = TRUE
    )

  cropped

}
