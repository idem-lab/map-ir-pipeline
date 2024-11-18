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
                            covariates_not_to_lag,
                            covariates_to_lag,
                            lags = 0:3) {


  covariates_not_to_lag <- str_subset(
    string = names(data_with_spatial_covariates),
    pattern = "_\\d{4}",
    negate = TRUE
  )

  covariates_to_lag <- setdiff(
    names(data_with_spatial_covariates),
    covariates_not_to_lag
  ) |> str_remove_all("_\\d{4}$") |>
    unique()


  for(lag in lags) {
    for (cov in covariates_to_lag) {
      lag_year <- data_with_spatial_covariates$start_year - lag
      cov_names <- paste0(cov, "_", lag_year)
      new_cov_name <- paste0(cov, "_lag", lag)
      row_idx <- seq_len(nrow(data_with_spatial_covariates))
      df_mat <- data_with_spatial_covariates |>
        select(starts_with(covariates_to_lag)) |>
        as.matrix()
      col_idx <- match(cov_names, colnames(df_mat))
      lagged_inputs <- df_mat[cbind(row_idx, col_idx)]
      data_with_spatial_covariates[new_cov_name] <- lagged_inputs
    }
  }
  data_with_spatial_covariates |>
    select(
      any_of(covariates_not_to_lag),
      contains("_lag")
    )

}
