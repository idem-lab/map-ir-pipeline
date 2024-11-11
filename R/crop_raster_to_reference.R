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
crop_raster_to_reference <- function(raster, reference,
                                   data_type = c("continuous", "discrete")) {

  data_type <- rlang::arg_match(data_type, c("continuous", "discrete"))

  method <- switch(
    data_type,
    continuous = "bilinear",
    discrete = "near"
  )

  cropped <- resample(
    raster,
      reference,
      method = method
      ) |>
    mask(reference)

  cropped
}

crop_raster_to_shapefile <- function(raster,
                                     shapefile) {

  cropped <- crop(
    x = raster,
    y = shapefile,
    mask = TRUE
  )

  cropped
}
