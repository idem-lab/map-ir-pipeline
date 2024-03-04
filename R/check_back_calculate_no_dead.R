#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title

#' @return
#' @author njtierney
#' @export
check_back_calculate_no_dead <- function(moyes_data) {
  check_back_calculate <- moyes_data %>%
    mutate(
      no_dead_check = recalculate_no_dead(
        no_mosquitoes_tested,
        percent_mortality
      ),
      dead_comparison = no_dead_check - no_mosquitoes_dead,
      .after = no_mosquitoes_tested
    )

  table_check_0s <- table(check_back_calculate$dead_comparison)

  is_only_zeros <- all(check_back_calculate$dead_comparison == 0, na.rm = TRUE)

  if (!is_only_zeros) {
    warn("recalculate_no_dead doesn't match OG no_mosquitoes_dead column")
    ref_check <- check_back_calculate %>%
      filter(
        dead_comparison != 0
      )
    return(
      ref_check
    )
  } else {
    (
      return(
        "Checks have passed, well done! :)"
      )
    )
  }
}
