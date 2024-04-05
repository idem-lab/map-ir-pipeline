engine <- function(model) model$engine

engines <- function(models) map_chr(models, \(x) engine(x))
