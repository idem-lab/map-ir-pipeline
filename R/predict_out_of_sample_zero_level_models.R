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
predict_out_of_sample_zero_level_models <- function(in_sample_data =
                                                    ir_data_mn_star,
                                                    level_zero_model_list =
                                                    l_zero_model_list) {

  map(
    .x = level_zero_model_list,
    .f = \(x) fit(object = x, data = in_sample_data)
  )

}
