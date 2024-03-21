#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data
#' @param covariate_data
#' @param setup
#' @return
#' @author njtierney
#' @export
fit_inla <- function(ir_data,
                     covariate_data,
                     setup) {

  # Fit the whole L1 model to N* original data, using out of sample covariates
  # oos = out of sample
  # super learner = L1 model
  gp_inla_data_n_star_oos <- build_inla_data(
    ir_data = ir_data,
    # including the out of sample covariates
    covariate_data = covariate_data
  )

  # Fit the whole L1 model to N* original data, using out of sample covariates
  super_learner_oos <- gp_inla(
    data = gp_inla_data_n_star_oos,
    setup = setup
  )


}
