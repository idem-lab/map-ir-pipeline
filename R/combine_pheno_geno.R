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
combine_pheno_geno <- function(moyes_pheno_prepared,
                               moyes_geno_prepared) {

  geno_pheno_match <- check_pheno_geno_match(
    moyes_pheno_prepared,
    moyes_geno_prepared
  )

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
    ) %>%
    mutate(
      insecticide_id = as.integer(as.factor(insecticide))
    ) %>%
    # convert start_month, end_month, and end_year into integer
    # but first remove "NR" and set to NA
    mutate(
      across(
        c("start_month",
          "end_month",
          "end_year"),
        \(x) na_if(x, "NR")
      )
    ) %>%
    mutate(
      across(
        c("start_month",
          "end_month",
          "end_year"),
        as.numeric
      )
    )

}
