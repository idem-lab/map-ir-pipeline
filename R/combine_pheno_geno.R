#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_pheno_prepared
#' @param moyes_geno_prepared
#' @return
#' @author njtierney
#' @export
combine_pheno_geno <- function(moyes_pheno_prepared, moyes_geno_prepared) {

  bind_rows(
    phenotypic = moyes_pheno_prepared,
    genotypic = moyes_geno_prepared,
    .id = "type"
  ) %>%
    replace_no_dead_pct_mortality()

}
