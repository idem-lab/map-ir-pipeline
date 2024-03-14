#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param raster
#' @param predictions
#' @return
#' @author njtierney
#' @export
prediction_to_raster <- function(raster, predictions) {
  # getting the first layer raster
  prediction_raster <- raster[[1]]

  which_cells_not_missing <- which(!is.na(prediction_raster[]))

  prediction_raster[] <- NA
  prediction_raster[which_cells_not_missing] <- predictions$.pred

  prediction_raster
}
