#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param covariate_rasters
#' @param training_data
#' @param list_of_l0_models
#' @param inla_mesh_setup
#' @return
#' @author njtierney
#' @export
spatial_prediction <- function(covariate_rasters = raster_covariates,
                               training_data = ir_data_subset,
                               list_of_l0_models = model_list,
                               inla_mesh_setup = gp_inla_setup) {

  ir_data_subset_spatial_covariates <- join_rasters_to_mosquito_data(
    rasters = covariate_rasters,
    mosquito_data = training_data
  )


  rasters_for_inner_loop <- prepare_rasters_for_inner_loop(
    raster = covariate_rasters,
    training_data = training_data,
    models = list_of_l0_models
  )

  # preparation steps here to hang on to this larger list grouping
  # structure of rasters >> insect_id
  # so we need some way to name these rasters beforehand, so that
  # after we do prediction in this step we can
  # match each raster back to it's original raster
  flattened_names <- flatten_names(rasters_for_inner_loop)
  unfurled_rasters <- purrr::flatten(rasters_for_inner_loop)

  names(unfurled_rasters) <- flattened_names

  # predict out for each raster in rasters_for_inner_loop
  # full set of map data (environmental covariates and coords)
  # in this final step we take a set of rasters, pull out coords and env
  # covariates for each pixel, and use stacked generalisation to predict to
  # all of them, then put predicted IR values back in a raster of predictions.
  spatial_predictions <- map(
    .x = unfurled_rasters,
    .f = function(rasters){
      inner_loop(
        data = ir_data_subset_spatial_covariates,
        new_data = rasters,
        l_zero_model_list = list_of_l0_models,
        l_one_model_setup = inla_mesh_setup
      )
    }
  )

  spatial_predictions

}
