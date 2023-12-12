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
    # number of trees
    ntree = 1001,
    # rate of randomly sampling featured used for each tree
    col_sample_rate_per_tree = 0.8,
    # min number of observations per leaf
    node_size = 20
    ) %>%
    set_mode("regression") %>%
    set_engine("randomForest")

  model_spec

}
