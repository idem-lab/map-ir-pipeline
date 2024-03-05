#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param raster
#' @return
#' @author njtierney
#' @export
raster_to_df <- function(raster) {

  raster_tibble <- terra::as.data.frame(
    x = raster,
    xy = TRUE
  ) %>%
    as_tibble(
      .name_repair = make_clean_names
    ) %>%
    rename(
      latitude = x,
      longitude = y
    )

}
