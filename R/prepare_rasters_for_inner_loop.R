#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param raster
#' @param training_data
#' @return
#' @author njtierney
#' @export
prepare_rasters_for_inner_loop <- function(rasters,
                                           training_data,
                                           models) {

  insecticide_ids <- sort(unique(training_data$insecticide_id))
  chosen_year <- max(as.integer(training_data$start_year))

  rasters_as_data <- raster_to_df(rasters)

  rasters_w_basic_info <- rasters_as_data %>%
    mutate(
      start_year = chosen_year,
      start_month = 1,
      end_month = 12,
      end_year = chosen_year,
      int = 1,
      .before = everything()
    )

  prepared_rasters <- map(
    .x = insecticide_ids,
    .f = function(ids) {
      mutate(
        .data = rasters_w_basic_info,
        insecticide_id = ids,
        .before = everything()
        )
    }
  )

  names(prepared_rasters) <- glue("insect_id_{insecticide_ids}")

  prepared_rasters

}
