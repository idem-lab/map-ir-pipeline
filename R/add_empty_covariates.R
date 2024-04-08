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

  other_names <- map(rasters, \(x) setdiff(predictors, names(x)))

  # something like this?
  added_covariates <- map2(
    .x = rasters,
    .y = other_names,
    .f = function(x, y){
      add_new_columns(x, y, 0)
    }
  )

  added_covariates

}
