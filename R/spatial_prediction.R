#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param covariate_rasters
#' @param training_data
#' @param level_zero_models
#' @param inla_mesh_setup
#' @return
#' @author njtierney
#' @export
spatial_prediction <- function(covariate_rasters,
                               training_data,
                               level_zero_models,
                               inla_mesh_setup,
                               lags,
                               prediction_year_range) {

  ir_data_subset_spatial_covariates <- join_rasters_to_mosquito_data(
    rasters = covariate_rasters,
    mosquito_data = training_data,
    lags = lags
  )

  rasters_as_data <- raster_to_df(covariate_rasters) |>
    tibble::rowid_to_column("uid")

  prediction_insecticide_ids <- training_data %>%
    filter(type == "phenotypic") %>%
    pull(insecticide_id) %>%
    unique() %>%
    sort()

  all_years <- seq(min(inla_mesh_setup$meshes$temporal_mesh$loc),
                   max(inla_mesh_setup$meshes$temporal_mesh$loc))

  # adding in basic data to ensure the raster data can be passed along
  # for model fitting
  rasters_w_basic_info <- rasters_as_data %>%
    expand_grid(
      start_year = prediction_year_range,
      start_month = 1,
      end_month = 12,
      end_year = max(prediction_year_range),
      int = 1,
      # add all insecticide ids in training data to the prediction
      # (later add the years too)
      insecticide_id = prediction_insecticide_ids
    )

  basic_rasters_lagged_covariates <- lag_covariates(
    data_with_spatial_covariates = rasters_w_basic_info,
    covariates_not_to_lag = covariates_not_to_lag,
    covariates_to_lag = covariates_to_lag,
    lags = lags
  )

  # start_year = all_years
  # ) %>% mutate(
  #   end_year = start_year + 1
  # )

  # predict out for each raster in rasters_for_inner_loop
  # full set of map data (environmental covariates and coords)
  # in this final step we take a set of rasters, pull out coords and env
  # covariates for each pixel, and use stacked generalisation to predict to
  # all of them, then put predicted IR values back in a raster of predictions.
  spatial_predictions <- inner_loop(
    data = ir_data_subset_spatial_covariates,
    # new_data = rasters_w_basic_info,
    new_data = basic_rasters_lagged_covariates,
    level_zero_models = level_zero_models,
    level_one_model_setup = inla_mesh_setup
  )

  # add back on the info
  bind_cols(rasters_w_basic_info, spatial_predictions)


}
