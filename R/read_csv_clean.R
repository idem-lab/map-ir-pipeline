#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_data_path
#' @return
#' @author njtierney
#' @export
read_csv_clean <- function(path) {
  data_raw <- read_csv(
    file = path,
    name_repair = make_clean_names
  )

  data_raw
}
