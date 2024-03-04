#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param no_mosquitoes_dead
#' @param no_mosquitoes_tested
#' @return
#' @author njtierney
#' @export
percent_mortality <- function(no_mosquitoes_dead, no_mosquitoes_tested) {
  mortality <- no_mosquitoes_dead / no_mosquitoes_tested
  mortality_pct <- mortality * 100
  round(mortality_pct, 2)
}
