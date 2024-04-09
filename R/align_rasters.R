#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param raster_countries_trees
#' @param raster_countries_veg
#' @param raster_countries_coffee
#' @return
#' @author njtierney
#' @export
align_rasters <- function(raster_list, target_extent) {

  master_ext <- ext(target_extent)

  aligned_rasters <- map(
    .x = raster_list,
    .f = function(x){
      ext(x) <- master_ext
      x
    }
  )

  aligned_vrasters

}
