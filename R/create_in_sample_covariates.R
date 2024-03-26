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
create_in_sample_covariates <- function(workflow_list,
                                        data,
                                        n_insecticides) {

  names(workflow_list) <- paste0(".pred_", names(workflow_list))

  in_sample_covariates <- map_dfc(
    workflow_list,
    \(x) predict(x, data)
    ) %>%
    set_names(names(workflow_list))

  in_sample_covariates_insecticide <- create_insecticide_id_list(
    id = seq_len(n_insecticides),
    in_sample_covariates
  )

  in_sample_covariates_insecticide

}
