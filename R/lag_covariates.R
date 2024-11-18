#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param data_with_spatial_covariates
#' @param covariates_not_to_lag
#' @param lags
#' @return
#' @author njtierney
#' @export
lag_covariates <- function(data_with_spatial_covariates,
                           covariates_not_to_lag = NULL,
                           lags = 0:3) {

  data_spatial_covariate_long <- data_with_spatial_covariates |>
    pivot_longer(
      cols = -c("uid", "start_year", covariates_not_to_lag),
      names_to = c("variable", "year"),
      # find two groups - the first being the variable, the second the year
      # e.g., for irs_2000 we get variables: irs, year
      # for itn_use_2000 we get variables: itn_use, and year
      names_pattern = "(.*)_(\\d{4})"
    ) |>
    mutate(
      year = as.integer(year)
    )

  data_spatial_covariate_long_lag <- data_spatial_covariate_long |>
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
      year_lagged = start_year - lags
    ) |>
    filter(
      year_lagged == year
    ) |>
    select(
      -year,
      -year_lagged
    ) |>
    pivot_wider(
      names_from = c("lags"),
      values_from = -c("uid", "start_year", "lags", covariates_not_to_lag),
      names_sort = TRUE
    ) |>
    pivot_longer(
      cols = -c(uid, start_year, covariates_not_to_lag),
      names_to = c("variable", "lag"),
      names_pattern = "(.*)_(\\d{1})"
    ) |>
    mutate(
      lag = as.integer(lag)
    ) |>
    arrange(
      uid,
      start_year,
      variable,
      lag
    )  |>
    fill(
      value,
      .direction = "down"
    ) |>
    pivot_wider(
      names_from = c(variable, lag),
      values_from = value
    )

  data_spatial_covariate_long_lag

}
