#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param no_mosquitoes_tested
#' @param percent_mortality
#' @return
#' @author njtierney
#' @export
recalculate_no_dead <- function(no_mosquitoes_tested, percent_mortality) {

  round(no_mosquitoes_tested * (percent_mortality / 100))

}
