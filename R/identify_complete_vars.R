#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_subset_spatial_covariates
#' @return
#' @author njtierney
#' @export
identify_complete_vars <- function(all_spatial_covariates) {

  miss_vars <- miss_var_summary(all_spatial_covariates)

  miss_vars %>%
    filter(n_miss == 0) %>%
    pull(variable)

}
