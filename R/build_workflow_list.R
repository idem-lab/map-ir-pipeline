#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
build_workflow_list <- function(
    models,
    outcomes,
    predictors
    ) {

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
