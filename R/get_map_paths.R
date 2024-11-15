#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param nameme1
#' @return
#' @author njtierney
#' @export
get_map_paths <- function(dir) {

    rast_paths <- list.files(
      dir,
      pattern = "*.tif",
      full.names = TRUE
    )
    str_subset(
      rast_paths,
      "mask|ngaben",
      negate = TRUE
    )

}
