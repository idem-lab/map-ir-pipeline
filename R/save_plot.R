save_plot <- function(path,
                      raster,
                      shpf,
                      px_width = 3000,
                      px_height = 1600) {
  dir_create("plots")

  plot <- gg_pixel_map(raster,shpf) # pass shapefile to gg_pixel_map

  ggsave(filename = path,
         plot = plot,
         width = px_width,
         height = px_height,
         units = "px",
         bg = "white")
  path
}
