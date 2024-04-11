#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param training_data
#' @param model_list
#' @return
#' @author njtierney
#' @export
train_level_zero_models <- function(training_data,
                                    model_list) {

  trained_models <- map(
    .x = model_list,
    .f = \(x) fit_level_zero_model(data = training_data, model = x)
  )

  trained_models

}
