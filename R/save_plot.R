save_plot <- function(path, raster, px_width = 2000, px_height = 1600) {
  dir_create("plots")

  plot <- ggplot() +
    geom_spatraster(
      data = raster / 100
    ) +
    scale_fill_gradient(
      low = "black",
      high = "light green",
      labels = scales::percent,
      name = "Susceptibility",
      limits = c(0, 1),
      na.value = "transparent") +
    facet_wrap(~lyr, ncol = 2) +
    ggtitle(
      label = "Predicted susceptibility to insecticide classes",
      subtitle = "for *An. gambiae* complex vectors in WHO bioassays"
    ) +
    theme_minimal() +
    theme(axis.line = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          axis.title.x = element_blank(),
          axis.title.y = element_blank(),
          panel.background = element_blank(),
          panel.border = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          plot.background = element_blank(),
          plot.title = element_markdown(),
          plot.subtitle = element_markdown(),
          legend.title = element_markdown())

  ggsave(filename = path,
         plot = plot,
         width = px_width,
         height = px_height,
         units = "px",
         bg = "white")
  path
}
