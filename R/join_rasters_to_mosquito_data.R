#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#'
#' @param rasters
#' @param extract_method
#' @param covariates_not_to_lag
#' @param lags
#' @param mosquito_data
#'
#' @return
#' @author njtierney
#' @export
join_rasters_to_mosquito_data <- function(rasters = raster_covariates,
                                          mosquito_data = ir_data_subset,
                                          extract_method = "bilinear",
                                          lags = 0:3) {
  cli_inform(
    message = c(
      "Using extraction method: {.var {extract_method}}",
      "In {.fn join_rasters_to_mosquito_data}"
    )
  )

  data_pts <- vect(
    mosquito_data,
    geom = c("longitude", "latitude"),
    crs = "EPSG:4326"
    )

  ir_data_subset_spatial_covariates <- terra::extract(
    rasters,
    data_pts,
    method = extract_method,
    xy = TRUE,
    bind = TRUE
  ) |>
    as.data.frame() |>
    as_tibble(.name_repair = make_clean_names) |>
    rename(
      longitude = x,
      latitude = y
    ) |>
    relocate(
      latitude,
      longitude,
      .after = end_year
    ) |>
    mutate(
      across(
        .cols = everything(),
        .fns = impute_zero
      )
    )

  lagged_covariates <- lag_covariates(
    data_with_spatial_covariates = ir_data_subset_spatial_covariates,
    covariates_not_to_lag = covariates_not_to_lag,
    covariates_to_lag = covariates_to_lag,
    lags = lags
  )

  lagged_covariates

}
