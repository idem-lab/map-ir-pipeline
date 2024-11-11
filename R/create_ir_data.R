#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_geno_pheno
#' @return
#' @author njtierney
#' @export
create_ir_data <- function(moyes_geno_pheno) {
  drop_na(
    data = moyes_geno_pheno,
    latitude,
    longitude,
    no_mosquitoes_tested,
    no_mosquitoes_dead,
    percent_mortality,
    start_month,
    end_month,
    start_year,
    end_year
  ) %>%
    rowid_to_column(
      var = "uid"
    ) |>
    select(-theta_ihs)
}
