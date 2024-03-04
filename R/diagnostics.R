#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_mn_oos_predictions
#' @return
#' @author njtierney
#' @export
diagnostics <- function(ir_data_mn_oos_predictions) {
  ggplot(
    ir_data_mn_oos_predictions,
    aes(
      x = .pred,
      y = percent_mortality
    )
  ) +
    geom_point()
}
