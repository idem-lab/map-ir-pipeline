#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param in_sample_data
#' @param level_zero_model_list
#' @return
#' @author njtierney
#' @export
predict_out_of_sample_level_zero_models <- function(in_sample_data,
                                                    level_zero_model_list,
                                                    new_data,
                                                    n_insecticides) {

  in_sample_predictions <- map(
    .x = level_zero_model_list,
    .f = \(x) fit(object = x, data = in_sample_data)
  )


  in_sample_covariates <- create_in_sample_covariates(
    workflow_list = in_sample_predictions,
    data = new_data,
    n_insecticides = n_insecticides
  )

  in_sample_covariates

}
