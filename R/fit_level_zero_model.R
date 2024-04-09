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
fit_level_zero_model <- function(data,
                                 model) {
  fits <- map(data, \(x) fit(model, data = x))

  fits
}
