save_plot <- function(path,
                      plot,
                      px_width = 3000,
                      px_height = 1600) {
  dir_create("plots")

  ggsave(filename = path,
         plot = plot,
         width = px_width,
         height = px_height,
         units = "px",
         bg = "white")
  path
}
