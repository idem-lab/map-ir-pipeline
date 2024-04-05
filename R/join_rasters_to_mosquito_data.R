#' .. content for \description{} (no empty lines) ..
#'
#' .. content for \details{} ..
#'
#' @title
#' @param rasters
#' @param mosquito_data
#' @return
#' @author njtierney
#' @export
join_rasters_to_mosquito_data <- function(rasters = raster_covariates,
                                          mosquito_data = ir_data_subset) {
  extracted_raster_covariates <- extract_from_rasters(
    rasters,
    mosquito_data
  )

  all_spatial_covariates <- reduce(
    .x = extracted_raster_covariates,
    .f = left_join,
    by = c("uid", "country")
  ) %>%
    # impute 0 into missing values for all rasters
    mutate(
      across(
        .cols = everything(),
        .fns = impute_zero
      )
    )

  ir_data_subset_spatial_covariates <- left_join(
    mosquito_data,
    all_spatial_covariates,
    by = c("uid", "country")
  )

  ir_data_subset_spatial_covariates

}
