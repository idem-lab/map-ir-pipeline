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
crop_raster_to_reference <- function(raster,
                                     reference,
                                     data_type = c("continuous", "discrete"),
                                     impute_value = NULL) {

  data_type <- rlang::arg_match(data_type, c("continuous", "discrete"))

  method <- switch(
    data_type,
    continuous = "bilinear",
    discrete = "near"
  )

  do_imputation <- !is.null(impute_value)
  if (do_imputation){
    raster[is.na(raster)] <- impute_value
  }

  # this is also cropping down to the extent of the "reference" raster
  resampled <- resample(
    raster,
    reference,
    method = method
  )

  masked <- mask(resampled, reference)

  masked
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
