#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param id
#' @param in_sample_covariates
#' @return
#' @author njtierney
#' @export
create_insecticide_id_list <- function(id = 1:5, in_sample_covariates) {

  map(
    .x = id,
    .f = \(x) mutate(in_sample_covariates, insecticide_id = x)
  )

}
