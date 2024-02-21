#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_subset
#' @param extracted_coffee
#' @param extracted_vege
#' @param extracted_trees
#' @param extracted_elevation
#' @param extracted_climate
#' @return
#' @author njtierney
#' @export
join_extracted <- function(extracted_coffee,
                           extracted_vege,
                           extracted_trees,
                           extracted_elevation,
                           extracted_climate) {
  extracted_coffee %>%
    left_join(extracted_vege,
              by = "uid") %>%
    left_join(extracted_trees,
              by = "uid") %>%
    left_join(extracted_elevation,
              by = "uid") %>%
    left_join(extracted_climate,
              by = "uid")
}
