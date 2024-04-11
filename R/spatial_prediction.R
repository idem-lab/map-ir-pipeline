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
spatial_prediction <- function(covariate_rasters = raster_covariates,
                               training_data = ir_data_subset,
                               level_zero_models = model_list,
                               inla_mesh_setup = gp_inla_setup) {

  ir_data_subset_spatial_covariates <- join_rasters_to_mosquito_data(
    rasters = covariate_rasters,
    mosquito_data = training_data
  )

  chosen_year <- max(as.integer(training_data$start_year))

  rasters_as_data <- raster_to_df(covariate_rasters)

  ## TODO
  ## I'm not sure on the values that we want to provide here for this raster
  ## currently this just gives them some choice start year, month, end year,
  ## end month, and also sets insecticide_id to be 1
  ## Later on the model gets fit with each insecticide, but I'm a little bit
  ## uncertain here of this process, so just flagging this
  rasters_w_basic_info <- rasters_as_data %>%
    mutate(
      start_year = chosen_year,
      start_month = 1,
      end_month = 12,
      end_year = chosen_year,
      int = 1,
      # dummy to be changed later?
      insecticide_id = 1,
      .before = everything()
    )

  # predict out for each raster in rasters_for_inner_loop
  # full set of map data (environmental covariates and coords)
  # in this final step we take a set of rasters, pull out coords and env
  # covariates for each pixel, and use stacked generalisation to predict to
  # all of them, then put predicted IR values back in a raster of predictions.
  spatial_predictions <- inner_loop(
        data = ir_data_subset_spatial_covariates,
        new_data = rasters_w_basic_info,
        level_zero_models = level_zero_models,
        level_one_model_setup = inla_mesh_setup
      )

  spatial_predictions

}
