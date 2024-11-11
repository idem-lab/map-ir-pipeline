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
  ir_data |>
    mutate(
      inv_pct_mort = Inv.IHS(
        x = percent_mortality,
        theta = theta
      ),
      prop_susceptible = inv_emplogit2(emp_logit = inv_pct_mort,
                                       N = no_mosquitoes_tested)
    )
}

