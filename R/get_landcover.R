#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param nameme1
#' @return
#' @author njtierney
#' @export
get_landcover <- function(var = "trees") {

  landcover(
    var = "trees",
    path = "data/rasters"
  )

}
