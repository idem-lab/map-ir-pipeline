#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_subset
#' @return
#' @author njtierney
#' @export
create_insecticide_id_lookup <- function(ir_data_subset) {

  data_unit <- ir_data_subset |>
    distinct(insecticide, insecticide_id) |>
    arrange(insecticide_id)

  insecticide_unit <- data_unit$insecticide
  names(insecticide_unit) <- data_unit$insecticide_id

  insecticide_unit
}
