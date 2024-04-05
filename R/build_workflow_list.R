#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
build_workflow_list <- function(
    models = list(
      model_xgb,
      model_rf
    ),
    outcomes = "percent_mortality",
    predictors = model_covariates) {

  workflows <- map(
    .x = models,
    .f = function(model){
      build_workflow(
        model_spec = model,
        outcomes = outcomes,
        predictors = predictors
      )
    }
  )

  engine_names <- engines(models)
  named_workflows <- setNames(workflows, engine_names)
  named_workflows

}
