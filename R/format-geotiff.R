format_geotiff <- tar_format(
  read = function(path) terra::rast(path),
  write = function(object, path) {
    terra::writeRaster(
      x = object,
      filename = path,
      filetype = "GTiff",
      overwrite = TRUE
    )
  },
  marshal = function(object) terra::wrap(object),
  unmarshal = function(object) terra::unwrap(object)
)


format_geotiffs <- tar_format(
  read = function(path) purrr::map(path, terra::rast),
  write = function(object, path) {
    purrr::walk2(
      .x = object,
      .y = path,
      .f = function(x, y) {
        terra::writeRaster(
          x = x,
          filename = y,
          filetype = "GTiff",
          overwrite = TRUE
        )
      }
    )
  },
  marshal = function(object) purrr::map(object, terra::wrap),
  unmarshal = function(object) purrr::map(object, terra::unwrap)
)
