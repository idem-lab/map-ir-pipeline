#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_mn
#' @param out_of_sample_predictions
#' @return
#' @author njtierney
#' @export
add_oos_predictions <- function(ir_data_mn, out_of_sample_predictions) {
  ir_data_mn %>%
    mutate(
      oos_preds = out_of_sample_predictions,
      .after = percent_mortality
    )
}
