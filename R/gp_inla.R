#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param data
#' @param setup
#' @return
#' @author njtierney
#' @export
gp_inla <- function(data,
                    setup) {
  fit <- fit(data$workflow, as.data.frame(data$data))

  fit
}
