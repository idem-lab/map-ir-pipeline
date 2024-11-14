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

  # example lagging code
  n <- 100

  grid_cov <- expand_grid(
    covariates = c("rainfall", "temperature"),
    years = 2000:2022,
    row = seq_len(n)
  ) |>
    mutate(
      value = runif(n())
    )

  grid_cov

  wider_grid_cov <- grid_cov |>
    pivot_wider(
      names_from = c(covariates, years),
      values_from = value
    )

  wider_grid_cov

  dat <- tibble(
    row = seq_len(n),
    obs = runif(n),
    year_start = sample(2000:2022, size = n, replace = TRUE)
  )

  dat

  example_covariates <- left_join(
    dat,
    wider_grid_cov,
    by = "row"
  ) |>
    mutate(
      coffee = runif(n())
    )

  covariates_to_lag <- c("rainfall", "temperature")
  covariates_not_to_lag <- c("coffee")
  covariates_to_lag

  vec_lags <- 0:3

  example_covariates |>
    select(
      -all_of(c(covariates_not_to_lag, "obs"))
    ) |>
    pivot_longer(
      cols = -c("row", "year_start"),
      names_to = c("variable", "year"),
      names_sep = "_"
    ) |>
    pivot_wider(
      names_from = variable,
      values_from = value
    ) |>
    # add an expand.grid with the lags as well
    expand_grid(
      lags = vec_lags
    ) |>
    relocate(
      lags,
      .after = year_start
    ) |>
    # so whether year_start - lag is equal to that year
    mutate(
      year_lagged = year_start - lags,
      year = as.integer(year),
      .after = lags
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
      values_from = covariates_to_lag
    )

}
