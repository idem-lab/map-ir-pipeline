#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param all_spatial_covariates
#' @return
#' @author njtierney
#' @export
get_covariate_names <- function(
    complete_spatial_covariates,
    remove_vars = c(
      "uid",
      "country",
      "percent_mortality",
      "type",
      "insecticide",
      "no_mosquitoes_tested",
      "no_mosquitoes_dead"
      )
    ) {
  vars_to_remove <- paste0(remove_vars,collapse = "|")
  str_subset(complete_spatial_covariates, vars_to_remove, negate = TRUE)
}
