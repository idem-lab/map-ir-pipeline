save_plot <- function(path, raster, px_width = 1600, px_height = 1600) {
  dir_create("plots")
  png(path, width = px_width, height = px_height, units = "px")
  plot(raster)
  dev.off()
  path
}
