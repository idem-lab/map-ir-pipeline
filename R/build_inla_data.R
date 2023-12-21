#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data
#' @param covariate_data
#' @return
#' @author njtierney
#' @export
build_inla_data <- function(ir_data,
                            covariate_data) {

  model_spec <-  linear_reg() %>%
    set_mode("regression") %>%
    set_engine("lm")

  covariate_names <- covariate_data %>%
    select(-starts_with("fold")) %>%
    names()

  workflow <- build_workflow(model_spec,
                             outcomes = "pct_mortality",
                             predictors = covariate_names)

  data <- bind_cols(select(ir_data, pct_mortality),
                    covariate_data)

  return(
    list(workflow = workflow,
         data = data)
  )
}
