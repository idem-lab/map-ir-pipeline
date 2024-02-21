#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param moyes_data_path
#' @return
#' @author njtierney
#' @export
read_csv_clean <- function(moyes_data_path) {

  moyes_raw <- read_csv(
    file = moyes_data_path,
    name_repair = make_clean_names
    )

  moyes_raw

}
