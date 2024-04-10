#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param outer_loop_results
#' @return
#' @author njtierney
#' @export
create_pixel_map_data <- function(predictions = outer_loop_results_spatial,
                              rasters = raster_covariates) {
  # TODO
  # make this work for all rasters
  # getting the first layer raster
  prediction_raster <- rasters[[1]]

  which_cells_not_missing <- which(!is.na(prediction_raster[]))

  # construct .pred_insecticide_id_{num}
  # .pred <- glue(".pred_insectide_id_{insecticide_id}")

  # TODO
  # make this work for all rasters
  prediction_raster[] <- NA
  prediction_raster[which_cells_not_missing] <- predictions[[1]][[1]]

  prediction_raster
}
