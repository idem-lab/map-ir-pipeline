#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param train_predict
#' @return
#' @author njtierney
#' @export
extract_predict <- function(train_predict) {
  map(train_predict$splits, testing) %>%
    map(\(x) filter(x, type == "phenotypic"))
}
