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
  prediction_raster <- rasters[[1]]

  which_cells_not_missing <- which(!is.na(prediction_raster[]))

  prediction_raster[] <- NA

  prediction_rasters <- map(
    .x = predictions,
    .f = function(predictions){
      `[<-`(prediction_raster, which_cells_not_missing, value = predictions)
    }
  )

  rast(prediction_rasters)
}
