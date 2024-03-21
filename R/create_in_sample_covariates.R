#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param workflow_list
#' @param data
#' @return
#' @author njtierney
#' @export
create_in_sample_covariates <- function(workflow_list = list(
                                          rf = zero_level_in_sample_rf,
                                          xgb = zero_level_in_sample_xgb
                                        ),
                                        data = new_data) {

  names(workflow_list) <- paste0(".pred_", names(workflow_list))

  in_sample_covariates <- map_dfc(
    workflow_list,
    \(x) predict(x, data)
    ) %>%
    set_names(names(workflow_list))

  in_sample_covariates

}
