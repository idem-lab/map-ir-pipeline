save_plot <- function(path, thing) {
  dir_create("plots")
  png(path)
  plot(thing)
  dev.off()
  path
}
