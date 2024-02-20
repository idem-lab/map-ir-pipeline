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


