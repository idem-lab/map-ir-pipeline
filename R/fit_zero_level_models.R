#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param data
#' @param model
#' @return
#' @author njtierney
#' @export
fit_zero_level_models <- function(data, model_list) {


  zero_level_models <- map(
    .x = model_list,
    .f = \(x) fit_zero_level_model(data = data,
                                   model = x)
  )

  zero_level_models

}
