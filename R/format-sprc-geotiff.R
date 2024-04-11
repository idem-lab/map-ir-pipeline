format_sprc_geotiff <- tar_format(
  read = function(path) terra::sprc(path),
  write = function(object, path) {
    for (i in seq(object)) {
      if (i > 1) {
        opt <- "APPEND_SUBDATASET=YES"
      } else opt <- ""
      terra::writeRaster(
        x = object[i],
        filename = path,
        filetype = "GTiff",
        overwrite = (i == 1),
        gdal = opt
      )
    }
  },
  marshal = function(object) terra::wrap(object),
  unmarshal = function(object) terra::unwrap(object)
)
