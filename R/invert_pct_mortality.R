#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data
#' @param theta
#' @param use_infinite_sample whether to convert from logits to percent
#'   mortality assume an infinite sample size (inverse logit transform), to get
#'   predicted population-level susceptibility or a known finite sample size
#'   (inverse empirical logit transform) to get the expected percent mortality
#'   (and number dead) in a sample fo known size. If FALSE, the column
#'   `no_mosquitoes_tested` must be present in `ir_data`.
#' @return
#' @author njtierney
#' @export
invert_pct_mortality <- function(ir_data,
                                 theta,
                                 outcome,
                                 use_infinite_sample = FALSE){

  # undo the IHS transform, using the optimised value of theta used in the
  # transform
  res <- ir_data |>
    mutate(
      logit_pct_mortality = Inv.IHS(
        # nominally, this is transformed_mortality
        # but could also equally be `.pred`
        x = {{ outcome }},
        theta = theta
      )
    )

  if (use_infinite_sample) {
    # if using an infinite sample (ie. for prediction to new locations), use the
    # inverse logit. plogis() (CDF of a logistic distribution) implements this.
    res <- res |>
      mutate(
        percent_mortality = 100 * plogis(logit_pct_mortality)
      )
  } else {
    # if not using an infinite sample (ie. comparison with observed test data),
    # use the inverse of the empirical logit, with the provided number of
    # mosquitoes tested, to get the number predicted dead, then compute the
    # empricial percent mortality.
    res <- res |>
      mutate(
        no_mosquitoes_dead_pred = inv_emplogit2(emp_logit = logit_pct_mortality,
                                                N = no_mosquitoes_tested),
        percent_mortality = 100 * no_mosquitoes_dead_pred / no_mosquitoes_tested
      )
  }

  res

}

