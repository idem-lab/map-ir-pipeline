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
model_validation <- function(covariate_rasters = all_spatial_covariates,
                             training_data = ir_data_mn_folds,
                             list_of_l0_models = model_list,
                             inla_mesh_setup = gp_inla_setup) {

  ir_data_subset_spatial_covariates <- left_join(
    training_data,
    covariate_rasters,
    by = c("uid", "country")
  )

  ## TODO
  ## Does insecticide_id need to be a factor? It's currently an integer
  ## Converting it to factor breaks the analysis ()
  ## Returns one set of predictions because we fit the L1 model
  ## out from the L0 models in here
  ## NOTE - this is to evaluate how good our model/process is
  ## API Note - this part is separate to the raster prediction step,
  ## ## so we might want to consider keeping this as a logical/flagging
  ## ## step so we

  # m = Number of rows of full **genotypic** data
  # n = Number of rows of full **phenotypic** data
  # m + n = Number of rows of full dataset
  ir_data_mn_folds <- vfold_cv(
    ir_data_subset_spatial_covariates,
    v = 10,
    strata = type
  )

  # then on the full dataset run 10 fold CV of the entire inner loop
  # Every time we run inner loop, pass in N* = N x 0.9, and M* = M x 0.9
  # Every time we run inner loop, we give it a prediction set
  # N x 0.1 and M x 0.1

  # ---- model validation ---- #
  # We need to fit each of the L0 models, 11 times
  # TODO: we need to do something special to appropriately handle
  # how the V-fold CV data, `ir_data_mn` works here, but for demo purposes
  # we will just assume that it runs on every fold separately.
  # we can probably do something with map, or have `inner_loop_cv` or
  # `inner_loop.vfold_cv` or something.

  training_data <- map(ir_data_mn_folds$splits, training)
  testing_data <- map(ir_data_mn_folds$splits, testing)

  model_for_validation <- map2(
    .x = training_data,
    .y = testing_data,
    .f = function(.x, .y) {
      inner_loop(
        data = .x,
        new_data = .y,
        l_zero_model_list = list_of_l0_models,
        l_one_model_setup = inla_mesh_setup
      )
    }
  )

  model_for_validation

}
