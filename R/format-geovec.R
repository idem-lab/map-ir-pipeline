format_geovec <- tar_format(
  read = function(path) terra::vect(path),
  write = function(object, path) {
    terra::writeVector(
      x = object,
      filename = path,
      filetype = "ESRI Shapefile",
      overwrite = TRUE
    )
  },
  marshal = function(object) terra::wrap(object),
  unmarshal = function(object) terra::unwrap(object)
)


