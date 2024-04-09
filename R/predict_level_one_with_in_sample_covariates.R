#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param in_sample_covariates
#' @param super_learner_fits
#' @return
#' @author njtierney
#' @export
predict_level_one_with_in_sample_covariates <- function(in_sample_covariates,
                                                        super_learner_fits) {
  ## TODO
  ## L1 model gets fit here with .pred as covariates
  ## AND the original response data as the response
  ## which is the (transformed percent_mortality)
  ## we ONLY do this for phenotypic data for a single insecticide
  ## fit as lm model for now
  # But we switch out-of-sample L0 covariates for L0 **in-sample covariates**
  # that gives a prediction of length N*
  gp_inla_data_n_star_is_pred <- map_dfc(
    .x = in_sample_covariates,
    .f = \(x) predict(super_learner_fits, x)
  ) %>% rename_to_pred_insectide_id()
}
