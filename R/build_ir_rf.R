#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
build_ir_rf <- function(mtry = 150,
                        trees = 1001,
                        min_n = 20) {

  model_spec <-  rand_forest(
    # num variables randomly sampled at each split
    mtry = mtry,
    # number of trees, previously `ntree`
    trees = trees,
    # min number of observations per leaf, previously `node_size`
    min_n = min_n
    ) %>%
    set_mode("regression") %>%
    set_engine("randomForest")

  model_spec

}
