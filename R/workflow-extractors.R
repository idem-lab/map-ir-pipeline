workflow_outcomes <- function(workflow){
  eval_tidy(workflow$pre$actions$variables$variables$outcomes)
}

workflow_predictors <- function(workflow){
  eval_tidy(workflow$pre$actions$variables$variables$predictors)
}
