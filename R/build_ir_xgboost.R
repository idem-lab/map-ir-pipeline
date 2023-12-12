#' Fit specific model of the IR xgboost
#'
#' Using specified hard coded hyperparameters
#'
#' @return
#' @author njtierney
#' @export
build_ir_xgboost <- function() {

  model_spec <- boost_tree(
    # max depth of a tree
    max_depth = 8,
    # number of trees
    nrounds = 12000,
    # learning rate
    eta = 0.001,
    # min los reduction required to make a further partition
    gamma = 0.5,
    # minimum sum of instance weight needed in a child
    min_child_weight = 7,
    # subsample ratio of columns when constructing a tree
    colsample_by_tree = 0.7,
    # subsample ratio of the training instance
    subsample = 0.7,
    # proportion of trees dropped each iteration
    rate_drop = 0.001,
    # regularisation parameter
    lambda = 1
  ) %>%
    set_mode("regression") %>%
    set_engine("xgboost")

  model_spec

}
