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
fit_zero_level_model <- function(data,
                                 model) {

  fits <- map(data, function(x) fit(model, data = as.data.frame(x)))

  fits
}
