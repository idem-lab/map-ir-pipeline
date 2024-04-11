#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param paths
#' @param rasters
#' @return
#' @author njtierney
#' @export
save_plots <- function(paths = pixel_map_paths, rasters = pixel_maps) {
  dir_create("plots")

  walk2(
    .x = paths,
    .y = rasters,
    .f = function(pp, rr){
      png(pp)
      plot(rr)
      dev.off()
    }
  )

  paths

}
