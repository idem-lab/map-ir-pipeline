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
combine_pheno_geno <- function(geno_pheno_match,
                               moyes_pheno_prepared,
                               moyes_geno_prepared) {

  if (!geno_pheno_match$match) {
    abort("Genotypic and Phenotypic data do not match, see `geno_pheno_match`")
  }

  bind_rows(
    phenotypic = moyes_pheno_prepared,
    genotypic = moyes_geno_prepared,
    .id = "type"
  ) %>%
    replace_no_dead_pct_mortality() %>%
    # perform the emplogit on response, and do IHS transform
    add_pct_mortality(
      no_dead = no_mosquitoes_dead,
      no_tested = no_mosquitoes_tested
    )

}
