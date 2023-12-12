#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
build_ir_bgam <- function() {

  model_spec <- boost_gam(
    # final number of iterations
    mstop = 80000,
    # degrees of freedom of the base learners
    degree = 1,
    # shrinkage parameter
    nu = 0.4
  ) %>%
  set_mode("regression") %>%
  set_engine("mboost")



}
