#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data
#' @param response
#' @return
#' @author njtierney
#' @export
construct_model_formula <- function(ir_data,
                                    covariate_names,
                                    response) {

  # double check covariate names are in ir_data
  check_if_covariate_names_in_data(covariate_names, ir_data)

  rhs <- paste0(covariate_names, collapse = " + ")
  lhs <- response
  formula_chr <- glue("{lhs} ~ {rhs}")

  as.formula(formula_chr)

}
