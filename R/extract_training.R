#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param train_predict
#' @return
#' @author njtierney
#' @export
extract_training <- function(train_predict) {

  map(train_predict$splits, training)

}
