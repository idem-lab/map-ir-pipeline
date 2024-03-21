#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param models
#' @param data
#' @return
#' @author njtierney
#' @export
fit_model_list <- function(models,
                           data) {

  map(
    .x = models,
    .f = \(x) fit(object = x, data = data)
  )

}
