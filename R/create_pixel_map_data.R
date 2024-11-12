#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param outer_loop_results
#' @return
#' @author njtierney
#' @export
create_pixel_map_data <- function(predictions,
                                  rasters) {

  # make a multiband raster, covering each insecticide type
  insecticide_ids <- sort(unique(predictions$insecticide_id))
  n_insecticides <- length(insecticide_ids)

  prediction_raster <- rasters[[1]]
  which_cells_not_missing <- which(!is.na(prediction_raster[]))
  prediction_raster[] <- NA
  prediction_raster_list <- replicate(n_insecticides,
                                      prediction_raster,
                                      simplify = FALSE)

  prediction_stack <- do.call(c, prediction_raster_list)
  names(prediction_stack) <- paste0("insecticide_", insecticide_ids)

  for (i in seq_len(n_insecticides)) {

    these_predictions <- predictions %>%
      filter(insecticide_id == insecticide_ids[i]) %>%
      pull(percent_mortality)

    prediction_stack[[i]][which_cells_not_missing] <- these_predictions

  }

  prediction_stack
}
