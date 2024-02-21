#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param all_spatial_covariates
#' @return
#' @author njtierney
#' @export
get_covariate_names <- function(all_spatial_covariates) {

  covariate_names <- names(all_spatial_covariates)

  str_subset(covariate_names, "uid", negate = TRUE)

}
