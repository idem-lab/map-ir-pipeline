#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param ir_data_raw
#' @param no_dead
#' @param no_tested
#' @return
#' @author njtierney
#' @export
add_transformed_mortality <- function(ir_data_raw, no_dead, no_tested) {
  # ==== Create pcent_mortality transformed variable ====
  # Empirical logit and IHS transform on labels
  ir_data_emp <- ir_data_raw %>%
    mutate(
      logit_pct_mortality = emplogit2(
        {{ no_dead }},
        {{ no_tested }}
      )
    )

  theta2 <- optimise(
    f = IHS.loglik,
    lower = 0.001,
    upper = 50,
    x = ir_data_emp$logit_pct_mortality,
    maximum = TRUE
  )

  ir_data <- ir_data_emp %>%
    mutate(
      theta_ihs = theta2$maximum,
      transformed_mortality = IHS(
        logit_pct_mortality,
        theta_ihs
      ),
      # add an intercept
      int = 1
    ) %>%
    # drop the emplogit thing because this is just an aux variable
    select(-logit_pct_mortality)

  ir_data
}
