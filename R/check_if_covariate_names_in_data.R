#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param covariate_names
#' @param ir_data
#' @return
#' @author njtierney
#' @export
check_if_covariate_names_in_data <- function(
    covariate_names,
    ir_data,
    arg_cov = caller_arg(covariate_names),
    arg_ir = caller_arg(ir_data),
    call = caller_env()) {
  covariate_names_in_data <- all(covariate_names %in% names(ir_data))
  if (!covariate_names_in_data) {
    cli::cli_abort(
      message = c(
        "covariate names are not all in data",
        "check {.code {all(covariate_names %in% names(ir_data))}",
        "for more details"
      ),
      call = call,
    )
  }
}
