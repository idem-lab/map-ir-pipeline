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
  the_raster <- landcover(
    var = var,
    path = "data/rasters"
  )

  the_raster
}
