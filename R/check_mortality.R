#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_moyes
#' @return
#' @author njtierney
#' @export
check_mortality <- function(moyes_pheno_prepared) {
  moyes_pheno_prepared

  ir_subset <- moyes_pheno_prepared %>%
    select(
      no_mosquitoes_tested,
      no_mosquitoes_dead,
      percent_mortality
    )

  ir_check_mortality <- ir_subset %>%
    mutate(
      pct_mort_check = pct_mortality(
        no_mosquitoes_dead,
        no_mosquitoes_tested
      ),
      pct_mort_near = near(pct_mort_check, percent_mortality, tol = 0.01)
    )

  ir_check_mortality %>%
    pull(pct_mort_near) %>%
    table()
}
