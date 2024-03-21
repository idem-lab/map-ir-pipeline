#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param training_data
#' @param testing_data
#' @param model_list
#' @return
#' @author njtierney
#' @export
train_and_predict_zero_level_model <- function(train_predict,
                                               model_list) {

  # this should be N* + M*
  train_data_mn_star <- extract_training(train_predict)
  # this should just be N*
  predict_data_nstar <- extract_predict(train_predict)

  zero_level_oos_mn_star <- fit_zero_level_models(
    data = training_data,
    model_list = model_list
  )

  # these prediction vectors should happen on each list of `predict_data`
  # these will be of length N*
  # oos = out of sample
  oos_predictions_l0 <- predict_models(
    data = testing_data,
    models = zero_level_oos_mn_star
  )

  oos_predictions_l0

}
