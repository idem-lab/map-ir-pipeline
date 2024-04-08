add_new_columns <- function(data, cols, values){
  `<-`(`[`(data, cols), value = values)
  data
}
