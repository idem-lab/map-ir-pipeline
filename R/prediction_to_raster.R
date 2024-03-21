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
prediction_to_raster <- function(raster, predictions, insecticide_id) {
  # getting the first layer raster
  prediction_raster <- raster[[1]]

  which_cells_not_missing <- which(!is.na(prediction_raster[]))

  # construct .pred_insecticide_id_{num}
  .pred <- glue(".pred_insectide_id_{insecticide_id}")

  prediction_raster[] <- NA
  prediction_raster[which_cells_not_missing] <- predictions[[.pred]]

  prediction_raster
}
