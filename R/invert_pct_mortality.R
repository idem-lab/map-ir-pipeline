#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data
#' @param theta
#' @return
#' @author njtierney
#' @export
invert_pct_mortality <- function(ir_data, theta){
  res <- ir_data |>
    mutate(
      inv_pct_mort = Inv.IHS(
        x = transformed_mortality,
        theta = theta
      ),
      no_mosquitoes_dead2 = inv_emplogit2(emp_logit = inv_pct_mort,
                                       N = no_mosquitoes_tested)
    )
}

