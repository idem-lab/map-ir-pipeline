#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param rasters
#' @param countries
#' @return
#' @author njtierney
#' @export
crop_many_rasters_many_countries <- function(rasters, countries) {
  grid_response <- expand_grid(
    rasters,
    countries
  )

  grid_cropped <- grid_response %>%
    mutate(
      cropped_rasters = map2(
        .x = rasters,
        .y = countries,
        .f = crop_raster_to_country
      )
    )

  grid_cropped$cropped_rasters
}
