#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data
#' @param covariate_data
#' @param level_one_model_setup
#' @return
#' @author njtierney
#' @export
fit_super_learner <- function(ir_data = ir_data_n_star, covariate_data =
                              oos_covariates, level_one_model_setup =
                              l_one_model_setup) {

  # Fit the whole L1 model to N* original data, using out of sample covariates
  gp_inla_data_n_star_oos <- build_inla_data(
    ir_data = ir_data,
    # including the out of sample covariates
    covariate_data = covariate_data
  )

  # Fit the whole L1 model to N* original data, using out of sample covariates
  # oos = out of sample
  # super learner = L1 model
  super_learner_oos <- gp_inla(
    data = gp_inla_data_n_star_oos,
    setup = level_one_model_setup
  )

}
