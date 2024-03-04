#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param out_of_sample_predictions
#' @return
#' @author njtierney
#' @export
combine_predictions <- function(pred_list) {
  pred_list

  folds <- select(pred_list[[1]], fold)

  predictions <- map_dfc(pred_list, \(x) select(x, starts_with(".pred")))

  bind_cols(
    folds,
    predictions
  )
}
