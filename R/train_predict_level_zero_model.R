#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param train_predict_data
#' @param level_zero_models
#' @return
#' @author njtierney
#' @export
train_predict_level_zero_model <- function(train_predict_data,
                                           level_zero_models) {

  # 10 times to get the 10 folds out of sample predictions
  ## The generalisation step
  # Train on 90% ((N* + M*) x 0.9), predict on 10% (N* x 0.1)

  ## generalisation folds: training and out of sample prediction
  train_predict_data <- vfold_cv(
    data = train_predict_data,
    v = 10
  )

  # this should be N* + M*
  train_data_mn_star <- extract_training(train_predict_data)
  # this should just be N*
  predict_data_nstar <- extract_predict(train_predict_data)
  # this should fit 10 models - preparing for out of sample (oos)
  # currently splitting into two steps as the model takes a long time to fit
  # and we are going to need to have a deeper think about cpu efficiency
  level_zero_oos_mn_star <- train_level_zero_models(
    training_data = train_data_mn_star,
    model_list = level_zero_models
  )

  # these prediction vectors should happen on each list of `predict_data`
  # these will be of length N*
  # oos = out of sample
  oos_predictions <- map(
    .x = level_zero_oos_mn_star,
    .f = \(x) predict_model(data = predict_data_nstar, model = x)
  )

  # Take out of sample predictions for each models, and combine to length N*
  # into fixed effects, one per model (XBG, RF, BGAM), A 3xN* matrix
  oos_covariates <- combine_predictions(oos_predictions)

  oos_covariates

}
