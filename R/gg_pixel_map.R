#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param pixel_maps_data
#' @return
#' @author njtierney
#' @export
gg_pixel_map <- function(pixel_maps_data) {

  plot <- ggplot() +
    geom_spatraster(
      data = pixel_maps_data / 100
    ) +
    scale_fill_gradient(
      low = "black",
      high = "light green",
      labels = scales::percent,
      name = "Susceptibility",
      limits = c(0, 1),
      na.value = "transparent"
    ) +
    facet_wrap(
      ~lyr,
      ncol = 4,
      labeller = as_labeller(insecticide_labeller)
    ) +
    labs(
      title = "Predicted susceptibility to insecticide classes",
      subtitle = "for *An. gambiae* complex vectors in WHO bioassays"
    ) +
    theme_void() +
    theme(
      plot.title = element_markdown(),
      plot.subtitle = element_markdown(),
      legend.title = element_markdown(),
      legend.position = "bottom"
    )

  plot

}
