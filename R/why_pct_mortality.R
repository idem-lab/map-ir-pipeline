#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_moyes_prepared
#' @return
#' @author njtierney
#' @export
why_pct_mortality <- function(ir_data_moyes_raw) {

  ir_data_moyes_raw %>%
    select(
      no_mosquitoes_tested,
      no_mosquitoes_dead,
      percent_mortality
      ) %>%
    filter(
      # no_mosquitoes_tested == "NR" & no_mosquitoes_dead == "NR"
      is.na(no_mosquitoes_tested) & is.na(no_mosquitoes_dead)
      # !is.na(percent_mortality)
    )

}
