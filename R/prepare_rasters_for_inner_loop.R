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
prepare_rasters_for_inner_loop <- function(rasters = covariate_rasters,
                                           training_data = training_data) {
  insecticide_ids <- unique(training_data$insecticide_id)
  chosen_year <- max(as.integer(training_data$start_year))

  rasters_as_data <- map(as.list(rasters), raster_to_df)

  rasters_w_year <- map(
    .x = rasters_as_data,
    .f = \(x) mutate(x, start_year = chosen_year, .before = everything())
  )

  prepared_rasters <- map(
    .x = rasters_w_year,
    .f = function(raster_data) {
      map(
        .x = insecticide_ids,
        \(x) mutate(raster_data,
          insecticide_id = x,
          .before = everything()
        )
      )
    }
  )

  unfurled_rasters <- purrr::flatten(prepared_rasters)

  unfurled_rasters
}
