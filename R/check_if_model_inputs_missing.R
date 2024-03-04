#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param model_covariates
#' @param ir_data_subset_spatial_covariates
#' @return
#' @author njtierney
#' @export
check_if_model_inputs_missing <- function(model_covariates,
                                          ir_data_subset_spatial_covariates) {
  ir_data_subset_spatial_covariates %>%
    select(
      all_of(model_covariates)
    ) %>%
    miss_var_summary()
}
