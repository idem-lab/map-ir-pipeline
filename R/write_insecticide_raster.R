#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param pixel_maps_data
#' @param insecticide_names
#' @return
#' @author njtierney
#' @export
write_insecticide_raster <- function(pixel_maps_data,
                                     insecticide_names) {

  dir_create("output-data")

  year_range <- parse_number(names(pixel_maps_data))
  year_txt <- paste0(year_range, collapse = '-')
  raster_file_name <- glue(
    "output-data/{year_txt}-{insecticide_names}-esimated-mortality.tif"
    )
  writeRaster(
    x = pixel_maps_data,
    filename = raster_file_name,
    overwrite = TRUE
  )

  raster_file_name

}
