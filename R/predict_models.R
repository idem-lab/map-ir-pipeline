#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param data
#' @param models
#' @return
#' @author njtierney
#' @export
predict_models <- function(data = predict_data_nstar,
                           models = zero_level_oos_mn_star) {

  model_predictions <- map(
    .x = models,
    .f = \(x) predict_model(data = data, model = x)
  )

  model_predictions

}
