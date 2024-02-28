#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_pheno_prepared
#' @param nameme1
#' @return
#' @author njtierney
#' @export
class_table <- function(data, type){
  class_list <- map_chr(data, class)
  class_table <- tibble(
    vars = names(class_list),
    class_list
  ) %>%
    rename(
      !!type := class_list
    )
  class_table
}
