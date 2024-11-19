#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param string
#' @return
#' @author njtierney
#' @export
insecticide_labeller <- function(string) {

  # "2014_carbamate" --> "Carbamate class - 2014"
  str_pieces <- str_split(string, pattern = "_", n = 2, simplify = TRUE)
  str_years <- str_pieces[ , 1]
  str_insecticides <- str_to_title(str_pieces[ , 2])
  glue("{str_insecticides} class - {str_years}")

}
