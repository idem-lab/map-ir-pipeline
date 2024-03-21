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
  model_spec <- linear_reg() %>%
    set_mode("regression") %>%
    set_engine("lm")

  covariate_names <- covariate_data %>%
    select(-starts_with("fold")) %>%
    names() %>%
    c(., "insecticide_id")

  workflow <- build_workflow(model_spec,
    outcomes = "percent_mortality",
    predictors = covariate_names
  )

  data <- bind_cols(
    select(ir_data, percent_mortality, insecticide_id, type),
    covariate_data
  )

  return(
    list(
      workflow = workflow,
      data = data
    )
  )
}
