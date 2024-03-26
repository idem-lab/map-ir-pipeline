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
train_zero_level_models <- function(training_data,
                                    model_list) {

  trained_models <- map(
    .x = model_list,
    .f = \(x) fit_zero_level_model(data = training_data, model = x)
  )

  trained_models

}
