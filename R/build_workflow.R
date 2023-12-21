#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param model_spec
#' @param outcomes
#' @param predictors
#' @return
#' @author njtierney
#' @export
build_workflow <- function(model_spec,
                           outcomes,
                           predictors) {

  model_workflow <- workflow() %>%
    add_model(spec = model_spec) %>%
    add_variables(
      outcomes = outcomes,
      predictors = predictors
    )

  model_workflow

}
