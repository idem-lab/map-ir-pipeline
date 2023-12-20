#' Fit specific model of the IR xgboost
#'
#' Using specified hard coded hyperparameters
#'
#' @return
#' @author njtierney
#' @export
build_ir_xgboost <- function() {

  model_spec <- boost_tree(
    # max depth of a tree, previously `max_depth`
    tree_depth = 8,
    # number of trees, previously `nrounds`
    trees = 12000,
    # learning rate, previously `eta`
    learn_rate = 0.001,
    # min los reduction required to make a further partition, previously `gamma`
    loss_reduction = 0.5,
    # minimum sum of instance weight needed in a child, prev: `min_child_weight`
    min_n = 7,
    # subsample ratio of the training instance, previously `subsample`
    sample_size = 0.7,
    # subsample ratio of columns when constructing a tree
    # previously `colsample_by_tree`
    mtry = 0.7
  ) %>%
    set_mode("regression") %>%
    set_engine("xgboost",
               # regularisation parameter
               lambda = 1,
               # proportion of trees dropped each iteration
               rate_drop = 0.001)

  model_spec

}
