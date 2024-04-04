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

  covariate_df <- join_rasters_to_mosquito_data(
    rasters = covariate_rasters,
    mosquito_data = training_data
  )

  ir_data_subset_spatial_covariates <- left_join(
    training_data,
    covariate_df,
    by = c("uid", "country")
  )


  rasters_for_inner_loop <- prepare_rasters_for_inner_loop(
    raster = covariate_rasters,
    training_data = training_data
  )

  # predict out for each raster in rasters_for_inner_loop
  # full set of map data (environmental covariates and coords)
  # in this final step we take a set of rasters, pull out coords and env
  # covariates for each pixel, and use stacked generalisation to predict to
  # all of them, then put predicted IR values back in a raster of predictions.
  spatial_predictions <- map(
    .x = rasters_for_inner_loop,
    .f = function(rasters){
      inner_loop(
        data = ir_data_subset_spatial_covariates,
        new_data = rasters,
        l_zero_model_list = model_list,
        l_one_model_setup = gp_inla_setup
      )
    }
  )

}
