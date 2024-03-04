#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param all_spatial_covariates
#' @return
#' @author njtierney
#' @export
get_covariate_names <- function(complete_spatial_covariates) {
  str_subset(complete_spatial_covariates, "uid|country", negate = TRUE)
}
