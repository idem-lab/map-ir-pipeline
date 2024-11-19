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
  insecticide_names_print <- stringr::str_to_sentence(insecticide_names)

  # currently only works for single year prediction
  # TODO
  # probably rename "year"
  year <- unique(predictions$start_year)
  n_insecticides <- length(insecticide_ids)
  n_years <- length(year)
  n_rasters <- n_insecticides * n_years

  prediction_raster <- rasters[[1]]
  which_cells_not_missing <- which(!is.na(prediction_raster[]))
  prediction_raster[] <- NA
  prediction_raster_list_years <- replicate(n_years,
                                            prediction_raster,
                                            simplify = FALSE)

  prediction_stack_years <- do.call(c, prediction_raster_list_years)

  names(prediction_stack_years) <- year

  prediction_stack_list <- replicate(n_insecticides,
                                     prediction_stack_years,
                                     simplify = FALSE)

  names(prediction_stack_list) <- insecticide_names_print

  # label_df <- tibble(insecticide_names_print) |>
  #   rowid_to_column() |>
  #   expand_grid(year) |>
  #   arrange(year, rowid) |>
  #   mutate(
  #     label = glue("{insecticide_names_print} class - {year}")
  #   )

  for (i in seq_len(n_insecticides)){
    for (y in seq_along(year)) {
      these_predictions <- predictions |>
        filter(start_year == year[y],
               insecticide_id == insecticide_ids[i]) |>
        pull(percent_mortality)
      prediction_stack_list[[i]][[y]][which_cells_not_missing] <- these_predictions
    }
  }

  prediction_stack_list
}
