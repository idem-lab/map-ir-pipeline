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
check_pheno_geno_match <- function(moyes_pheno_prepared, moyes_geno_prepared) {

  names_match <- all(names(moyes_pheno_prepared) == names(moyes_geno_prepared))

  if (!names_match){
    abort("names of data do not match")
  }

  pheno_class <- class_table(moyes_pheno_prepared, "pheno")
  geno_class <- class_table(moyes_geno_prepared, "geno")

  matched_data <- left_join(
    pheno_class,
    geno_class,
    by = "vars"
  )  %>%
    mutate(
      match = pheno == geno
    ) %>%
    arrange(match)

  return(
    list(
      match = names_match,
      data = matched_data
    )
  )


}
