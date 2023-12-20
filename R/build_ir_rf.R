#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
build_ir_rf <- function() {

  model_spec <-  rand_forest(
    # num variables randomly sampled at each split
    mtry = 150,
    # number of trees, previously `ntree`
    trees = 1001,
    # min number of observations per leaf, previously `node_size`
    min_n = 20
    ) %>%
    set_mode("regression") %>%
    set_engine("randomForest")

  model_spec

}
