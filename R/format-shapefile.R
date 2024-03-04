format_shapefile <- tar_format(
  read = function(path) terra::vect(paste0("/vsizip/", file.path(path, gsub("\\.zip", ".shp", basename(path))))),
  write = function(object, path) {
    terra::writeVector(
      x = object,
      filename = gsub("\\.zip", ".shp", basename(path)),
      filetype = "ESRI Shapefile",
      overwrite = TRUE
    )
    zf <- list.files(pattern = gsub("\\.zip", "", basename(path)))
    utils::zip(path, zf)
    unlink(zf)
  },
  marshal = function(object) terra::wrap(object),
  unmarshal = function(object) terra::unwrap(object)
)
