#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param covariate_rasters
#' @param training_data
#' @param level_zero_models
#' @param inla_setup
#' @return
#' @author njtierney
#' @export
model_validation <- function(covariate_rasters,
                             training_data,
                             level_zero_models,
                             inla_setup,
                             lags) {

  ir_data_subset_spatial_covariates <- join_rasters_to_mosquito_data(
    rasters = covariate_rasters,
    mosquito_data = training_data,
    lags = lags
  )

  # Returns a set of predictions per test set, fitting L1 model from L0 models
  # to evaluate how good our model/process is

  # m = Number of rows of full **genotypic** data
  # n = Number of rows of full **phenotypic** data
  # m + n = Number of rows of full dataset
  ir_data_mn_folds <- vfold_cv(
    ir_data_subset_spatial_covariates,
    v = 10,
    strata = type
  )

  # On the full dataset run 10 fold CV of the entire inner loop
  # Every time we run inner loop, pass in N* = N x 0.9, and M* = M x 0.9
  # Every time we run inner loop, we give it a prediction set
  # N x 0.1 and M x 0.1

  training_data <- map(ir_data_mn_folds$splits, training)
  testing_data <- map(ir_data_mn_folds$splits, testing)

  # The level 1 model only considers phenotypic data (though we train the L0 on
  # genottypic too), so only retain phenotypic data in the testing data here
  testing_data_pheno <- testing_data %>%
    map(\(x) filter(x, type == "phenotypic"))

  out_of_sample_predictions <- map2(
    .x = training_data,
    .y = testing_data_pheno,
    .f = function(.x, .y) {
      inner_loop(
        data = .x,
        new_data = .y,
        level_zero_models = level_zero_models,
        level_one_model_setup = inla_setup
      )
    }
  )

  # recombine them, fold-wise
  combined_predictions <- map2(
    .x = out_of_sample_predictions,
    .y = testing_data_pheno,
    .f = bind_cols
  )

  # combine folds
  bind_rows(combined_predictions)

}
