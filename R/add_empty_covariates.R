#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param rasters
#' @param models
#' @return
#' @author njtierney
#' @export
add_empty_covariates <- function(rasters = rasters_w_year, models = models) {
  predictors <- workflow_predictors(models[[1]])

  other_names <- map(rasters_w_year, \(x) setdiff(names(x, predictors)))
  # something like this?
  # rasters_w_year[[1]] %>%
  #   mutate(!!!other_names[[1]] = 0)
}
