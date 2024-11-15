#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param all_spatial_covariates
#' @param covariates_to_lag
#' @param covariates_not_to_lag
#' @param lags
#' @return
#' @author njtierney
#' @export
lag_covariates <- function(all_spatial_covariates,
                           covariates_to_lag,
                           covariates_not_to_lag = NULL,
                           lags = 0:3) {

  all_spatial_covariates |>
    # making a smaller subset so it is easier to understand for the moment
    select(
      -c(covariates_not_to_lag),
    ) |>
    pivot_longer(
      cols = -c("uid", "start_year"),
      names_to = c("variable", "year"),
      # find two groups - the first being the variable, the second the year
      # e.g., for irs_2000 we get variables: irs, year
      # for itn_use_2000 we get variables: itn_use, and year
      names_pattern = "(.*)_(\\d{4})"
    ) |>
    mutate(
      year = as.integer(year)
    ) |>
    pivot_wider(
      names_from = variable,
      values_from = value
    ) |>
    expand_grid(
      lags = lags
    ) |>
    relocate(
      lags,
      .after = year
    ) |>
    mutate(
      year_lagged = start_year - lags,
      .after = lags
    ) |>
    filter(
      year_lagged == year
    )  |>
    select(
      -year,
      -year_lagged
    ) |>
    pivot_wider(
      names_from = c("lags"),
      values_from = -c("uid", "start_year", "lags")
    )

}
