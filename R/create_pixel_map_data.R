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
                              rasters,
                              insecticide_lookup) {

  # make a multiband raster, covering each insecticide type
  insecticide_ids <- sort(unique(predictions$insecticide_id))

  insecticide_names <- insecticide_lookup[insecticide_ids]

  start_years_id <- sort(unique(predictions$start_year))
  end_years_id <- sort(unique(predictions$end_year))
  year_id <- glue("{start_years_id}-{end_years_id}")
  n_insecticides <- length(insecticide_ids)

  prediction_raster <- rasters[[1]]
  which_cells_not_missing <- which(!is.na(prediction_raster[]))
  prediction_raster[] <- NA
  prediction_raster_list <- replicate(n_insecticides,
                                      prediction_raster,
                                      simplify = FALSE)

  prediction_stack <- do.call(c, prediction_raster_list)
  names(prediction_stack) <- glue("insecticide_{insecticide_names}_{year_id}")

  for (i in seq_len(n_insecticides)) {

    these_predictions <- predictions %>%
      filter(insecticide_id == insecticide_ids[i]) %>%
      pull(.pred)

    prediction_stack[[i]][which_cells_not_missing] <- these_predictions

  }

  prediction_stack
}
