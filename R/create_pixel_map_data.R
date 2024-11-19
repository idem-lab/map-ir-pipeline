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
                                  insecticide_lookup,
                                  insecticide = insecticide_names) {

  # make a multiband raster, covering each insecticide type
  insecticide_ids <- sort(unique(predictions$insecticide_id))
  the_insecticide_id <- as.integer(which(insecticide_lookup == insecticide))

  insecticide_names_print <- stringr::str_to_sentence(insecticide)

  start_years <- unique(predictions$start_year)
  n_years <- length(start_years)

  prediction_raster <- rasters[[1]]
  which_cells_not_missing <- which(!is.na(prediction_raster[]))
  prediction_raster[] <- NA
  prediction_raster_list_years <- replicate(n_years,
                                            prediction_raster,
                                            simplify = FALSE)

  prediction_stack_years <- do.call(c, prediction_raster_list_years)

  names(prediction_stack_years) <- paste0(start_years, "_", insecticide)

  for (y in seq_along(start_years)) {
    these_predictions <- predictions |>
      filter(start_year == start_years[y],
             insecticide_id == the_insecticide_id) |>
      pull(percent_mortality)
    prediction_stack_years[[y]][which_cells_not_missing] <- these_predictions
  }

  prediction_stack_years
}
