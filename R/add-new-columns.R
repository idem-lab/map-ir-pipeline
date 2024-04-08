add_new_columns <- function(data, cols, values){
  `<-`(`[`(data, cols), values = values)
  data
}
