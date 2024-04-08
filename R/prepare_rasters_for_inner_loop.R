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
                                           training_data = training_data,
                                           models = list_of_l0_models) {
  insecticide_ids <- unique(training_data$insecticide_id)
  chosen_year <- max(as.integer(training_data$start_year))

  rasters_as_data <- map(as.list(rasters), raster_to_df)


  # adds covariates as 0s
  rasters_w_all_covariates <- add_empty_covariates(
    rasters = rasters_as_data,
    models = models
  )

  rasters_w_basic_info <- map(
    .x = rasters_w_all_covariates,
    .f = function(x){
      mutate(
        x,
        start_year = chosen_year,
        start_month = 1,
        end_month = 12,
        end_year = chosen_year,
        int = 1,
        # TODO - these variables seem important??
        # no_mosquitoes_tested...?
        # no_mosquitoes_dead...?
        .before = everything()
        )
    }
  )

  prepared_rasters <- map(
    .x = rasters_w_basic_info,
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
