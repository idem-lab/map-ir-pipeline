plot_raster_shape <- function(raster, shape){
  plot(
    raster,
    fun = \() lines(shape)
  )
}
