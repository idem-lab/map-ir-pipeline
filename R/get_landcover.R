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

  temp_path <- tempfile()

  the_raster <- landcover(
    var = var,
    path = temp_path
  )

  the_raster

}
