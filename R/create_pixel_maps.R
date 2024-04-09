#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param outer_loop_results
#' @return
#' @author njtierney
#' @export
create_pixel_maps <- function(predictions = outer_loop_results_spatial,
                              rasters = raster_covariates) {
  # getting the first layer raster
  prediction_raster <- rasters[[1]]

  which_cells_not_missing <- which(!is.na(prediction_raster[]))

  # construct .pred_insecticide_id_{num}
  .pred <- glue(".pred_insectide_id_{insecticide_id}")

  prediction_raster[] <- NA
  prediction_raster[which_cells_not_missing] <- predictions[[.pred]]

  prediction_raster
}
