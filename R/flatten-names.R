flatten_names <- function(some_special_rasters){
  parent_names <- names(some_special_rasters)
  child_names <- map(some_special_rasters, names)
  parent_child_crossing <- map2(
    .x = parent_names,
    .y = child_names,
    .f = function(x, y){
      paste(x, y, sep = "_")
    }
  )
  unlist(parent_child_crossing)
}
