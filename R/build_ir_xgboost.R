#' Fit specific model of the IR xgboost
#'
#' Using specified hard coded hyperparameters
#'
#' @return
#' @author njtierney
#' @export
build_ir_xgboost <- function(tree_depth = 8,
                             trees = 12000,
                             learn_rate = 0.001,
                             loss_reduction = 0.5,
                             min_n = 7,
                             sample_size = 0.7,
                             mtry = 0.7,
                             lambda = 1,
                             rate_drop = 0.001) {

  model_spec <- boost_tree(
    # max depth of a tree, previously `max_depth`
    tree_depth = tree_depth,
    # number of trees, previously `nrounds`
    trees = trees,
    # learning rate, previously `eta`
    learn_rate = learn_rate,
    # min los reduction required to make a further partition, previously `gamma`
    loss_reduction = loss_reduction,
    # minimum sum of instance weight needed in a child, prev: `min_child_weight`
    min_n = min_n,
    # subsample ratio of the training instance, previously `subsample`
    sample_size = sample_size,
    # subsample ratio of columns when constructing a tree
    # previously `colsample_by_tree`
    mtry = mtry
  ) %>%
    set_mode("regression") %>%
    set_engine("xgboost",
               # regularisation parameter
               lambda = lambda,
               # proportion of trees dropped each iteration
               rate_drop = rate_drop,
               counts = FALSE)

  model_spec

}
