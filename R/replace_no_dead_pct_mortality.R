#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_moyes_prepared
#' @return
#' @author njtierney
#' @export
replace_no_dead_pct_mortality <- function(ir_data_moyes_prepared) {
  ir_data_moyes_prepared %>%
    mutate(
      no_mosquitoes_dead = case_when(
        is.na(no_mosquitoes_dead) ~ recalculate_no_dead(
          no_mosquitoes_tested,
          percent_mortality
        ),
        .default = no_mosquitoes_dead
      ),
      percent_mortality = case_when(
        is.na(percent_mortality) ~ pct_mortality(
          no_mosquitoes_dead,
          no_mosquitoes_tested
        ),
        .default = percent_mortality
      )
    )
}
